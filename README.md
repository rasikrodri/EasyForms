What can easily be created with EasyForms:
-App UI
	-Windows
	-Tables
 	-Forms with controls
  	-Etc
-Game UI
-Etc


How to use the EasyFormRow node:

-Add an EasyFormsRow to the scene
-Add 2d node/nodes that has the 'size' property
-Set the EasyFormsRow settings in the inspector to alight it's content and aligth itself

-Add multiple EasyFormsRow as siblings and add child nodes tho them.
	The EasyFormsRow will act like a table aligned or disaligned accorditn to the settings you give to each of the EasyFormsRow



Limitations:
	-an EasyFormsRow cannot be a child of another EasyFormRow. This is not supported and probably will never be.
	-if an EasyFormsRow'sparent does not have the size property the viewport size will be used instead.
