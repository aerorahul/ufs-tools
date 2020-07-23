program read_fv3lam

  use mpp_mod, only: mpp_init, mpp_exit
  use mpp_mod, only: mpp_pe, mpp_npes, mpp_root_pe
  use mpp_io_mod, only: mpp_io_init, mpp_io_exit
  use mpp_domains_mod, only: domain2D, &
                             mpp_get_compute_domain, &
                             mpp_get_data_domain
  use mpp_domains_mod, only: east, north, center
  use fms_io_mod, only: fms_io_init, fms_io_exit


  use fv3lam_mod, only: geometry, setup_domain, field, read_field

  implicit none

  type(domain2D) :: domain
  integer :: npx, npy, npz, ntiles, nhalo
  integer :: layout(2), io_layout(2)
  integer :: halo
  integer :: ios, ierr
  integer :: funit = 10
  character(len=80) :: grid_name, grid_file

  character(len=80) :: restart_files(3)

  type(geometry) :: geom
  type(field) :: fld

  integer :: ii
  integer :: pe, npes, root_pe

  namelist /fv_grid_nml/ grid_name, grid_file
  namelist /fv_core_nml/ npx, npy, npz, ntiles, nhalo, layout, io_layout
  namelist /fv_rst_nml/ restart_files

  call mpp_init()
  call mpp_io_init()

  pe = mpp_pe()
  npes = mpp_npes()
  root_pe = mpp_root_pe()

  call fms_io_init()

  open(unit=funit, file='input.nml', iostat=ios)
  read(funit, fv_grid_nml, iostat=ios)
  read(funit, fv_core_nml, iostat=ios)
  read(funit, fv_rst_nml, iostat=ios)
  close(funit)

  geom%npx = npx
  geom%npy = npy
  geom%npz = npz
  geom%ntiles = ntiles
  geom%nhalo = nhalo
  geom%layout = layout
  geom%io_layout = io_layout

  if (pe == root_pe) then
    print*, 'npx, npy, npz = ', geom%npx, geom%npy, geom%npz
    print*, 'grid_file = ', grid_file
    do ii=1,3
      print*, 'restart_files = ', trim(restart_files(ii))
    enddo
  endif

  call setup_domain(geom%domain, geom%npx-1, geom%npy-1, geom%ntiles, geom%layout, geom%io_layout, geom%nhalo)
  call mpp_get_compute_domain(geom%domain, geom%isc, geom%iec, geom%jsc, geom%jec)
  call mpp_get_data_domain(geom%domain, geom%isd, geom%ied, geom%jsd, geom%jed)

  call fld%alloc_field(geom, 'T', 'temperature', restart_files(1), &
                       'magnitude', center, .false.)
  call read_field(fld)
  call fld%dealloc_field()


  call fms_io_exit()
  call mpp_io_exit()
  call mpp_exit()
  stop
end program read_fv3lam
