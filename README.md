# Inductor Optimizer
This repository was developed by two graduate students over the COVID-19 lockdown period to automate the design optimization of power inductor.

**Note:** The owners of this repository offer no warranties or assume any liability for anything arising out of use of this code. The license can be found [here](https://github.com/ngadiyar93/InductorOptimization/blob/master/LICENSE)

## Instructions to run the optimization

- Clone / download the repository to your computer
- Make sure FEMM is installed
- Run the file [OptimizeGA.m](https://github.com/ngadiyar93/InductorOptimization/blob/master/optimizeGA.m)

## Documentation

- The method adopted for BH curves, loss computation as well as details about the inductor core lookup table is found [here](https://github.com/ngadiyar93/InductorOptimization/blob/master/Core%20selection.pdf)
- A parameterized picture of the E-I core considered is available [here](https://github.com/ngadiyar93/InductorOptimization/blob/master/Parameterized%20Geometry.pdf)

## Limitations

- For now only one material and 5 E-I core variants are considered
- The loss computation considers only the core loss - proximity losses need to be added, skin effect needs to be considered
- The model needs to be made more detailed

## External references
The E-I core data can be found in the following links 
- Datasheet is [here](https://datasheets.micrometals.com/EFS-0130604-014-DataSheet.pdf)
- The product page is [here](https://www.micrometals.com/products/product-finder/?ordering=shapes&units=in&material=FS)
