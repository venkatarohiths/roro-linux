# Customization

- Add package: set `BR2_PACKAGE_<NAME>=y` in defconfig.
- Add files: place under `overlay/`.
- New target config: add `configs/<target>_defconfig`.
- Custom package: use Buildroot package infra under external tree.
