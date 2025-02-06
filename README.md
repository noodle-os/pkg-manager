# Noodle Package Manager

A simple package manager made for NoodleOS. Comes included with NoodleOS.

## Features
- Install, remove, list, and get info about packages.
- Lightweight and minimal dependencies.

## How to Use

### Installing a Package
To install a package, run:
```sh
noodle install <package_name>
```
Or use the shorthand:
```sh
noodle -i <package_name>
```

### Upgrading a Package
To upgrade a package to the latest version:
```sh
noodle upgrade <package_name>
```
Or use the shorthand:
```sh
noodle -u <package_name>
```

### Removing a Package
To remove an installed package:
```sh
noodle remove <package_name>
```
Or use the shorthand:
```sh
noodle -r <package_name>
```

### Listing Installed Packages
To see all installed packages, run:
```sh
noodle list
```
Or use the shorthand:
```sh
noodle -l
```

### Getting Package Info
To retrieve information about a specific package:
```sh
noodle info <package_name>
```
Or use the shorthand:
```sh
noodle -f <package_name>
```

## Find Packages
You can browse available packages [here](https://noodle-os.github.io/packages.html)

## Contributing
Pull requests are welcome! Feel free to submit issues or suggestions.

## License
This project is licensed under the MIT License.