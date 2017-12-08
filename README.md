B9Lab-ETH17-Splitter
====================

This is the Solidity-only solution to the Splitter problem presented at https://academy.b9lab.com/courses/course-v1:B9lab+ETH-17+2017-10/courseware/82c7df09b67c4f96818e0a32a59b6457/d5b4341029a249bdb438d5a87a9c5a94/ . In my interpretation of the text, any of Alice, Bob and Carol can send money to the other two users. Alice, Bob and Carol are 'constant': the users the contract was instantiated for originally, and do not change for the duration of the life of the contract. In other words, Alice, Bob and Carol are any three users, but always the same three.

The code currently includes the following "stretch goals":

- the "kill switch", on the tutor's suggestion, was changed to "pause" and "resume" functions, and are available to any of Alice, Bob and Carol
- the management of potentially bad input data.

This code is (C) Digital Contraptions Imaginarium Ltd. and released under the MIT licence.
