With EasyForms you can easily create app UI, app Windows, Tables, Forms with controls, Game UI, etc.

***Easyforms keep content aligned even if the viewport size changes!***

How to use the EasyFormRow node:

-Some times, like when a new EasyFormsRow is added or a child is added to an EasyFormsRow, you will need to click on the Update EasyFormsRows button in order to see the changes in the editor

-Add an EasyFormsRow to the scene
-Add 2d node/nodes that has the 'size' property
-Set the EasyFormsRow settings in the inspector to alight it's content and aligth itself

-Add multiple EasyFormsRow as siblings and add child nodes tho them.
	The EasyFormsRow will act like a table aligned or disaligned accorditn to the settings you give to each of the EasyFormsRow



Limitations:
	-an EasyFormsRow cannot be a child of another EasyFormRow. This is not supported and probably will never be.
	-if an EasyFormsRow'sparent does not have the size property the viewport size will be used instead.

 Examples:

Table
 ![image](https://github.com/user-attachments/assets/dc41e924-6e4a-4822-8414-e4afd90e6902)

 Log in form
https://github.com/user-attachments/assets/d0a1cc0a-8341-4be7-9f44-f3d8c3dfd3a5
 ![image](https://github.com/user-attachments/assets/215145c1-0084-4167-b3bc-1b9e6c672224)


