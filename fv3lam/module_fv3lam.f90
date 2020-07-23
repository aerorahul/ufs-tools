module fv3lam_mod

  use mpp_mod, only: mpp_pe, mpp_npes, mpp_error, FATAL, NOTE
  use mpp_domains_mod, only: domain2D, &
                             mpp_define_layout, &
                             mpp_define_mosaic, &
                             mpp_define_io_domain
  use mpp_domains_mod, only: east, north, center

  use fms_io_mod, only: restart_file_type, &
                        register_restart_field, &
                        free_restart_type, &
                        restore_state

  implicit none

  private
  public :: geometry, &
            field, &
            setup_domain, &
            read_field

  type geometry
    integer :: isd, ied, jsd, jed      !data domain
    integer :: isc, iec, jsc, jec      !compute domain
    integer :: npx, npy, npz           !x/y/z-dir grid edge points per tile
    integer :: nhalo                   !number of halo points
    integer :: layout(2), io_layout(2) !Processor layouts
    integer :: ntiles                  !Total tiles
    type(domain2D) :: domain           !MPP domain
  end type geometry

type field
  logical :: lalloc = .false.
  character(len=128) :: short_name = "null" !Short name (to match file name)
  character(len=128) :: long_name = "null"  !More descriptive name
  character(len=128) :: io_file = "null"    !Which restart to read/write
  logical            :: tracer = .false.    !Whether field is classified as tracer (pos. def.)
  character(len=128) :: space               !One of vector, magnitude, direction
  integer            :: position            !One of center, east, north corner
  type(geometry)     :: geom                !geometry of the field
  real(kind=4), allocatable, dimension(:,:,:) :: array
contains
  procedure :: alloc_field
  procedure :: dealloc_field
endtype field

contains

subroutine alloc_field(self, geom, short_name, long_name, &
                       io_file, space, position, tracer)

  class(field), target, intent(inout) :: self
  type(geometry),       intent(in)    :: geom
  character(len=*),     intent(in)    :: short_name
  character(len=*),     intent(in)    :: long_name
  character(len=*),     intent(in)    :: io_file
  character(len=*),     intent(in)    :: space
  integer,              intent(in)    :: position
  logical,              intent(in)    :: tracer

  self%geom = geom

  if (.not. self%lalloc) then
    if (position == center) then
      allocate(self%array(geom%isc:geom%iec, geom%jsc:geom%jec, 1:geom%npz))
    elseif (position == north) then
      allocate(self%array(geom%isc:geom%iec, geom%jsc:geom%jec+1, 1:geom%npz))
    elseif (position == east) then
      allocate(self%array(geom%isc:geom%iec+1, geom%jsc:geom%jec, 1:geom%npz))
    endif
  endif

  self%lalloc = .true.

  self%short_name   = trim(short_name)
  self%long_name    = trim(long_name)
  self%io_file      = trim(io_file)
  self%space        = space
  self%position     = position
  self%tracer       = tracer

end subroutine alloc_field

subroutine dealloc_field(self)

  class(field), intent(inout) :: self

  if(self%lalloc) deallocate(self%array)
  self%lalloc = .false.

end subroutine dealloc_field

subroutine setup_domain(domain, nx, ny, ntiles, layout_in, io_layout, halo)

 type(domain2D),   intent(inout) :: domain
 integer,          intent(in)    :: nx, ny, ntiles
 integer,          intent(in)    :: layout_in(:), io_layout(:)
 integer,          intent(in)    :: halo

 integer                              :: pe, npes, npes_per_tile, tile
 integer                              :: num_contact, num_alloc
 integer                              :: n, layout(2)
 integer, allocatable, dimension(:,:) :: global_indices, layout2D
 integer, allocatable, dimension(:)   :: pe_start, pe_end
 integer, allocatable, dimension(:)   :: tile1, tile2
 integer, allocatable, dimension(:)   :: istart1, iend1, jstart1, jend1
 integer, allocatable, dimension(:)   :: istart2, iend2, jstart2, jend2
 integer, allocatable :: tile_id(:)
 logical :: is_symmetry

  pe = mpp_pe()
  npes = mpp_npes()

  if (mod(npes,ntiles) /= 0) then
     call mpp_error(NOTE, "setup_domain: npes can not be divided by ntiles")
     return
  endif
  npes_per_tile = npes/ntiles
  tile = pe/npes_per_tile + 1

  if (layout_in(1)*layout_in(2) == npes_per_tile) then
     layout = layout_in
  else
     call mpp_define_layout( (/1,nx,1,ny/), npes_per_tile, layout )
  endif

  if (io_layout(1) <1 .or. io_layout(2) <1) call mpp_error(FATAL, &
       "setup_domain: both elements of variable io_layout must be positive integer")
  if (mod(layout(1), io_layout(1)) /= 0 ) call mpp_error(FATAL, &
       "setup_domain: layout(1) must be divided by io_layout(1)")
  if (mod(layout(2), io_layout(2)) /= 0 ) call mpp_error(FATAL, &
       "setup_domain: layout(2) must be divided by io_layout(2)")

  allocate(global_indices(4,ntiles), layout2D(2,ntiles), pe_start(ntiles), pe_end(ntiles) )

  ! select case based off of 1 or 6 tiles
  select case(ntiles)
  case ( 1 ) ! FV3-SAR
    num_contact = 0
  case ( 6 ) ! FV3 global
    num_contact = 12
  case default
    call mpp_error(FATAL, "setup_domain: ntiles != 1 or 6")
  end select

  do n = 1, ntiles
     global_indices(:,n) = (/1,nx,1,ny/)
     layout2D(:,n)       = layout
     pe_start(n)         = (n-1)*npes_per_tile
     pe_end(n)           = n*npes_per_tile-1
  enddo
  num_alloc = max(1, num_contact)
  ! this code copied from domain_decomp in fv_mp_mod.f90
  allocate(tile1(num_alloc), tile2(num_alloc) )
  allocate(tile_id(ntiles))
  allocate(istart1(num_alloc), iend1(num_alloc), jstart1(num_alloc), jend1(num_alloc) )
  allocate(istart2(num_alloc), iend2(num_alloc), jstart2(num_alloc), jend2(num_alloc) )

  is_symmetry = .true.
  do n = 1, ntiles
     tile_id(n) = n
  enddo

  call mpp_define_mosaic(global_indices, layout2D, domain, ntiles, num_contact, tile1, tile2, &
                         istart1, iend1, jstart1, jend1, istart2, iend2, jstart2, jend2,      &
                         pe_start, pe_end, whalo=halo, ehalo=halo, shalo=halo, nhalo=halo,    &
                         symmetry=is_symmetry, tile_id=tile_id, &
                         name='cubic_grid')

  if (io_layout(1) /= 1 .or. io_layout(2) /= 1) call mpp_define_io_domain(domain, io_layout)

  deallocate(pe_start, pe_end)
  deallocate(layout2D, global_indices)
  deallocate(tile1, tile2, tile_id)
  deallocate(istart1, iend1, jstart1, jend1)
  deallocate(istart2, iend2, jstart2, jend2)

end subroutine setup_domain

subroutine read_field(fld)

  type(field), intent(inout) :: fld

  type(restart_file_type) :: restart
  integer :: idrst

  ! Register restart
  idrst = register_restart_field(restart, trim(fld%io_file), &
                                 trim(fld%short_name), fld%array, &
                                 domain=fld%geom%domain, position=fld%position)
  ! read field
  call restore_state(restart)
  call free_restart_type(restart)

end subroutine read_field

end module fv3lam_mod
