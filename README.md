<snippet>
  <content>
# Basic Server Template (BST)
This is a very simple script that does the basics that you'd expect from a server.

I developed this over a weekend of having nothing to do and haven't used it in a real-server environment.

I have not played this game in 4+ years, but I do enjoy programming in Pawno so I thought I'd make an open source project.

I have no interest in being an admin/developer on any server so please do not ask. If you need help, let me know; do not assume I'll write code for you. I will only advice you on how to do it.

This script was made to mess around with mates, so it went from a random/stunt GM to a Roleplay one. It has both features, just edit to what you need.

## Features
The name gives it away, but this is a very basic script. The script is not rich in features, but gives you the chance to make it that way!

###Current supported version: SA-MP 0.3.7-R2
###Server plugins/includes
* MySQL database
* ZCMD
* sscanf2

####Script features
* Regsiter/login system (with MySQL database, encrypted passwords)
* Admin system (good amount of commands, just check out the comments within the code)
* Interiors for buildings
* Enter/Exit buildings pressing Y on keyboard or /enter || /exit
* Whole lot of weapons, vehicles, and other commands you may enjoy. It would be trivial typing them all out; the code is easy to read.


## Installation
1. Clone the repository `git clone https://github.com/aarogrammer/bst.git`
2. CD in to the directory `CD bst`
3. Make sure you're up-to-date and you'll be good to go!

## How to use
1. Make sure you have both the latest server package and the latest SA-MP gamemode client [https://www.sa-mp.com](https://www.sa-mp.com)
2. Change server.cfg to your need
### MySQL use
1. Make sure you have MySQL installed. Can use open source software such as WAMP, LAMP, XAMPP etc...
2. If above software, navigate to http://localhost/phpmyadmin
3. Create a new database
4. Create a table named `user` and add the following structure

 ![alt text](http://i.imgur.com/8UVZ5uw.png "MySQL database")
4. Head over to your servers directory, go to gamemodes and open the BST script
5. Scroll down until you see the defines for MySQL and change them accordingly:

`define db_host "127.0.0.1" //your host, usually localhost (127.0.0.1)`

`define db_user "root" //your MySQL database username`

`define db_pass "" //your MySQL database password`

`define db_db "samp" //your MySQL database name`


Double click samp-server.exe and the server will start.

If you have any errors, make sure to check the logs that are within your servers directory.

## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b branch-name`
3. Add files to staging `git add .`
4. Commit your changes: `git commit -m 'Here are my changes'`
5. Push to the branch: `git push origin branch-name`
6. Submit a pull request and I will look at it ASAP.

## Disclaimer
BST is not a finished gamemode and never will be.

BST is here to help players create thier own SA-MP server.

This means that YOU can help improve this script for others.

I take no responsibility if there is bugs in this script.

Create an issue on GitHub and if I can, I will fix it.

This is on GitHub so that others can improve it.


## Author
Aaron Welsh

[http://aaron-welsh.co.uk](http://aaron-welsh.co.uk)

[https://twitter.com/_aaronwelsh](https://twitter.com/_aaronwelsh)

## License
MIT
</content>
</snippet>
