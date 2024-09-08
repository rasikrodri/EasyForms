With EasyForms you can easily create app UI, app Windows, Tables, Forms with controls, Game UI, etc.

***How do EasyFormRows behave:***

-EasyFormsRows node move their children to fit it's available area. They will keep their children aligned even if the viewport size changes!

-EasyForms nodes will move their children to a new next row if it does not fit fully in the current row

***How to use the EasyFormRow node:***

-Some times, like when a new EasyFormsRow is added or a child is added to an EasyFormsRow, you will need to click on the Update EasyFormsRows button in order to see the changes in the editor

-Add an EasyFormsRow to the scene

-Add 2d node/nodes as children of the EasyFormsRow.

-Set the EasyFormsRow settings in the inspector to align it's childreb.

-Add multiple EasyFormsRow as siblings and add child nodes tho them.
	The EasyFormsRow will act like a table aligned or disaligned accorditn to the settings you give to each of the EasyFormsRow



Limitations:
	-an EasyFormsRow cannot be a child of another EasyFormRow. This is not supported and probably will never be.
	-if an EasyFormsRow's parent does not have the size property the viewport size will be used instead.

How to use:
-In the case of adding a new node as child of an EasyFormsRow you can click on the "Update EasyFormsRows" button to recalculate positions
![image](https://github.com/user-attachments/assets/3835502a-a989-483f-903f-5619b7055c5e)

Settings:
-Indepenedent - By default all siblings EasyFormsRows are calculated together as a family, but if you check "Independent" the EasyFormsRow will be treated as if the only child, and you can make as mabny as you want "independent".

Examples:

Table
![image](https://github.com/user-attachments/assets/c5ce1b0b-b92b-4b0b-bfa6-a30e919b6cbc)

 

https://github.com/user-attachments/assets/72065de7-f92d-4cb4-a7c5-1876852e9633



 Log in form
 
https://github.com/user-attachments/assets/d0a1cc0a-8341-4be7-9f44-f3d8c3dfd3a5

https://github.com/user-attachments/assets/dfbd1907-d854-45a2-af38-7c323645c9e3

