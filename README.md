WarGame
=======
Scott Thomas, 14 April 2011
  CSC 540A - Graduate Research Seminar
	Spring 2011 Semester
	
	This program plays the card game "war" and makes some experimental observations
	as to the odds of a player winning given a certain card set including:
	* having the highest sum
	* having the most Aces, Kings, Queens, Jacks, or Tens
	It also keeps track of the shortest, longest, and average game lengths
	as well as how many true tie games were encountered (A VERY rare occurence).
	
	This program uses a Player type that is a linked list implemented as a FIFO queue to hold
	each player's cards (each card being represented by a Node).  The temporary holding area
	for cards when the players are comparing cards or setting aside during a tie also implements
	this queue type.
	
	This program merely requires the user to input the number of games the user would like to play.
	The	output of the statistics are printed to the screen.

Please read the license in this repo regarding the use of this code.
