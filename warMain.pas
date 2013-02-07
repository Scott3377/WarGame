program war;
{
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
}

type 	NodePointer = ^Node;	{A pointer to the Node}
		
		{Node acts as a card (See below for help source)}
		Node = record
				  item: integer;
				  next: NodePointer;
			   end;
		
		{A Player class represented as a Queue (See below for help source)}
		Player = record
					head, tail: NodePointer;
					name: string;
					length: integer;
				end;
				
	{
	Henceforth referenced as "Source 1";
	Help on pointers from Google Book "Introduction to Pascal and Structured Design" By Nell Dale, Chip Weems.
	URL of resource:
		"http://books.google.com/books?id=5x2k4vWwn1wC&pg=PA782&lpg=PA782&dq=enqueue+pascal&source
		=bl&ots=rUbdoeRxwj&sig=DZqvN4HaPIfYsydiHIA-sqcrjr0&hl=en&ei=-nimTbHJN9OBtgf25MmFAQ&sa=X&oi=book_result&ct=
		result&resnum=3&ved=0CB8Q6AEwAg#v=onepage&q&f=false"
	}

var
	winner : string;			{Holds name of winner}
	highSumWins : qword = 0;		{Number of wins by player with highest sum}
	mostAcesWins : qword = 0;		{Number of wins by player with most Aces}
	mostKingsWins : qword = 0;		{Number of wins by player with most Kings}
	mostQueensWins : qword = 0;		{Number of wins by player with most Queens}
	mostJacksWins : qword = 0;		{Number of wins by player with most Jacks}
	mostTensWins : qword = 0;		{Number of wins by player with most Tens}
	mostAces : string;			{Holds name of player with most Aces}
	mostKings : string;		{Holds name of player with most Kings}
	mostQueens : string;		{Holds name of player with most Queens}
	mostJacks : string;		{Holds name of player with most Jacks}
	mostTens : string;			{Holds name of player with most Tens}
	highSum : string;			{Holds name of player with highestSum}
	sameSum : boolean = false;		{Tells whether the sum was the same for both players}
	sameAce : boolean = false;		{Tells whether the number of Aces was the same for both players}
	sameKing : boolean = false;		{Tells whether the number of Kings was the same for both players}
	sameQueen : boolean = false;	{Tells whether the number of Queens was the same for both players}
	sameJack : boolean = false;		{Tells whether the number of Jacks was the same for both players}
	sameTen : boolean = false;		{Tells whether the number of Tens was the same for both players}
	longestGame : qword = 0;		{Keeps track of the longest game}
	shortestGame : integer = 0;		{Keeps track of the shortest game}
	totalRounds : qword = 0;		{Keeps track of the number of rounds in a game}
	gamesToPlay : qword = 0;		{The number of games to play}
	cardDeck : array[1..52] of integer;		{The temporary card deck for shuffling cards}
	index : integer = 1;			{A reusable index variable for loops}
	index2 : integer = 1;			{A reusable index variable for loops}
	deckCtr : integer = 1;			{An index for placing cards in cardDeck}
	gameNum : qword = 1;			{Current game iteration number}
	deckIndex : integer = 0;		{Counter variable for size of deck after card is removed during shuffling}
	deckEnd : integer = 0;			{Keeps track of end of deck after a card is dealt to a player during shuffling}
	cardsLeft : integer = 0;		{Keeps track of number of cards left in deck after a card is dealt to a player during shuffling}
	player1 : Player;				{Player 1's Queue of cards}
	player2 : Player;				{Player 2's Queue of cards}
	temp : Player;					{Temporary Queue that holds cards pending reward}
	testArray1 : array[1..26] of integer;	{ Temporary array to hold cards while examining}
	testArray2 : array[1..26] of integer;	{...}
	p1sum : integer = 0;			{Sum of Player 1's card ranks}
	p2sum : integer = 0;			{Sum of Player 2's card ranks}
	p1Aces : integer = 0;			{Number of Player 1's Aces}
	p1Kings : integer = 0;			{Number of Player 1's Kings}
	p1Queens : integer = 0;			{Number of Player 1's Queens}
	p1Jacks : integer = 0;			{Number of Player 1's Jacks}
	p1Tens : integer = 0;			{Number of Player 1's Tens}
	player1Success : boolean = false;	{Tells who won last round (for determining rewards)}
	tie : boolean = false;			{Tells if there was a tie (skip reward section & go back to beginning)}
	numRounds : qword = 0;			{Counts the number of rounds it takes to finish a game}
	card1 : integer = 0;			{Player 1's card}
	card2 : integer = 0;			{Player 2's card}
	done : boolean = false;			{tells when tie has finished}
	player1Length : integer = 0;	{Number of cards Player 1 has}
	player2Length : integer = 0;	{Number of cards Player 2 has}
	trueTie : boolean = false;		{Very rare tie game scenario where both players run out of cards and tie}
	tieGames : integer = 0;			{Number of tie games}
	tempDouble : double = 0;		{Used to cast gamesToPlay to double for average calculations}
	playerLength : integer = 0;		{Used to hold the length of a queue(number of cards in player's hand)}
	StartTime : LongInt;			{Start time}
	EndTime : LongInt;				{End time}


{Initializes the Player object (constructor)}
procedure initialize(var p:Player);
begin
	p.head:=nil;
	p.tail:=nil;
	p.length:=0;	
end;

{Frees up the memory used by the queues by emptying them after each game}
{Got some help from http://www.learn-programming.za.net/programming_pascal_learn14.html}
procedure destroy(var p:Player);
var cur : NodePointer;
begin
	cur := p.head;	{Set current to beginning of the queue}
	while cur <> nil do	{While there is still an item in the queue}
	begin
		cur := cur^.next;	{Store the next item in current}
		dispose(p.head);	{Free memory used by head}
		p.head := cur;		{Set the new head of the queue to the current item}
	end;
end;

{Determines if a queue is empty or not}
function empty(var p:Player): boolean;
begin
	empty:=p.head=nil;
end;


{Inserts an item at the end (tail) of the queue}
{Got some help from Source 1 (Listed above)}
procedure enqueue(var p:Player;newItem : integer);
var
  tempVar : NodePointer;
begin
  New(tempVar);		{Create new Node}
  tempVar^.item:=newItem;
  tempVar^.next:=nil;

  if (not empty(p)) then
  begin
    p.tail^.next:=tempVar;
  end else begin
    p.head:=tempVar;
  end;
  p.tail:=tempVar;
  p.length := p.length + 1;
end;


{Removes the item currently at the front (head) of the queue, if one exists}
{Got some help from Source 1 (Listed above)}
function dequeue(var p:Player): integer;
var
  leadItem : integer;
  pointer: NodePointer;
begin
  if (not empty(p)) then
  begin
    pointer:=p.head;
    leadItem:=p.head^.item;
    p.head:=p.head^.next;
    dispose(pointer);	{Free memory used by item that has been dequeued}
    if (p.head=nil) then	{If the head is nil, then the list is empty and the tail is nil}
    begin
      p.tail:=nil;
    end;
    p.length:= p.length - 1;
    dequeue := leadItem;	{return card number}
  end;
end;


{Gets the length of the queue}
function getLength(var p:Player): integer;
begin
  getLength := p.length;
end;


{Sets the name of the player}
procedure setName(var p:Player; newName : string);
begin
  p.name := newName;
end;


{Gets the player's name}
function getName(var p:Player): string;
begin
  getName := p.name;
end;



begin {main program}
randomize;

{Get number of games to play}
writeln();
writeln('How many games would you like to play?');
writeln('(Keep in mind that 10,000 games takes approximately 1.5 seconds to play)');
readln(gamesToPlay);

StartTime := MemL[$40:$6C];

writeln();
writeln('Playing ',gamesToPlay,' games...taking approximately ',(gamesToPlay/7500):0:2,' seconds to complete');
writeln();

{----------------------------------------------------
				Begin Games loop
		(Play for number of games specified)
-----------------------------------------------------}
gameNum:=1;
repeat
	
	{Reinitialize numRounds}
	numRounds:=0;

	{Fill card deck}
	index:=2;
	deckCtr:=1;
	repeat
		index2:=1;
		repeat
			cardDeck[deckCtr] := index;
			index2:=index2 + 1;
			deckCtr:=deckCtr+1;
		until index2 > 4;
		index:=index + 1;
	until index>14;
	
	{Initialize number of cards left in deck (53 since random(x) is exclusive of x)}
	cardsLeft := 52;
	
	
	{Initialize Players and set names}
	initialize(player1);
	initialize(player2);
	setName(player1,'Player 1');
	setName(player2,'Player 2');
	
	{Initialize temporary reward queue}
	initialize(temp);
	
	
	{Deal Player 1's cards}
	index:=1;
	repeat
		{Get index of card to remove from deck}
		deckIndex := random(cardsLeft) + 1;
		enqueue(player1,cardDeck[deckIndex]);
		
		{Gets number of cards left in deck - 1 (for array index)}
		deckEnd := cardsLeft - 1;
		
		{Shift cards in array left after card removal}
		index2 := deckIndex;
		if index2 <= deckEnd then
		begin
			repeat
				cardDeck[index2] := cardDeck[index2 + 1];
				index2:=index2 + 1;
			until index2>deckEnd;
		end;
		
		{Decrement number of cards in cardDeck}
		cardsLeft := cardsLeft - 1;
		index:=index + 1;
	until index>26;
	
	
	{Deal Player 2's cards}
	index:=1;
	repeat
		{Get index of card to remove from deck}
		deckIndex := random(cardsLeft) + 1;
		enqueue(player2,cardDeck[deckIndex]);
		
		{Gets number of cards left in deck - 1 (for array index)}
		deckEnd := cardsLeft - 1;
		
		{Shift cards in array left after card removal}
		index2:=deckIndex;
		repeat
			cardDeck[index2] := cardDeck[index2 + 1];
			index2:=index2 + 1;
		until index2>deckEnd;
		
		{Decrement number of cards in cardDeck}
		cardsLeft := cardsLeft - 1;
		index:=index + 1;
	until index>26;

	
	{----------------------------------------------
	
	Do preliminary testing of player's hands
	
	------------------------------------------------}
	
	{Unload player's hands into test arrays for analysis}
	index:=1;
	repeat
			testArray1[index] := dequeue(player1);
			testArray2[index] := dequeue(player2);
			index:=index + 1;
	until index>26;
	
	{Refill player's hands from test arrays}
	index:=1;
	repeat
			enqueue(player1,testArray1[index]);
			enqueue(player2,testArray2[index]);
			index:=index + 1;
	until index>26;
	
	{Reinitialize player sums}
	p1Sum:=0;
	p2Sum:=0;
	
	{Calculate sum of player's hands}
	index:=1;
	repeat
		p1sum := p1sum + testArray1[index];
		p2sum := p2sum + testArray2[index];
		index:=index + 1;
	until index>26;
	
	{Reinitialize number of Aces, Kings, Queens, Jacks, Tens}
	p1Aces:=0;
	p1Kings:=0;
	p1Queens:=0;
	p1Jacks:=0;
	p1Tens:=0;
	
	{Count number of face cards (and Tens); Only need to keep track of Player 1's cards since their # will determine Player 2's}
	index:=1;
	repeat
		case testArray1[index] of
		14 : begin
				p1Aces := p1Aces + 1;
			end;
		13 : begin
				p1Kings := p1Kings + 1;
			end;
		12 : begin
				p1Queens := p1Queens + 1;
			end;
		11 : begin
				p1Jacks := p1Jacks + 1;
			end;
		10 : begin
				p1Tens := p1Tens + 1;
			end;
		end; {end case}
		index:=index + 1;
	until index>26; {end repeat}
	
	{See who has higher sum}
	if p1Sum>p2Sum then
	begin
		highSum := getName(player1);
	end else if p2Sum > p1Sum then
	begin
		highSum := getName(player2);
	end else
	begin
		sameSum := true;
	end;
	
	{See who has most Aces}
	if p1Aces>2 then
	begin
		mostAces := getName(player1);
	end else if p1Aces<2 then
	begin
		mostAces := getName(player2);
	end else
	begin
		sameAce := true;
	end;
	
	{See who has most Kings}
	if p1Kings>2 then
	begin
		mostKings := getName(player1);
	end else if p1Kings<2 then
	begin
		mostKings := getName(player2);
	end else
	begin
		sameKing := true;
	end;
	
	{See who has most Queens}
	if p1Queens>2 then
	begin
		mostQueens := getName(player1);
	end else if p1Queens<2 then
	begin
		mostQueens := getName(player2);
	end else
	begin
		sameQueen := true;
	end;
	
	{See who has most Jacks}
	if p1Jacks>2 then
	begin
		mostJacks := getName(player1);
	end else if p1Jacks<2 then
	begin
		mostJacks := getName(player2);
	end else
	begin
		sameJack := true;
	end;
	
	{See who has most Tens}
	if p1Tens>2 then
	begin
		mostTens := getName(player1);
	end else if p1Tens<2 then
	begin
		mostTens := getName(player2);
	end else
	begin
		sameTen := true;
	end;
	
	{-----------------------------
			Start game
	------------------------------}
	repeat
		
		{Increment number of rounds}
		numRounds := numRounds + 1;
	
		{Reinitialize win and tie variables for new round}
		player1Success := false;
		tie := false;
		
		{Each player lay down a card to compare}
		card1 := dequeue(player1);
		card2 := dequeue(player2);
		
		
		{Add these cards to temporary holding area for winner of round}
		{** Tricky ** Must be random or else could enter infinite loop}
		if (random() >= 0.5) then
		begin
			enqueue(temp,card1);
			enqueue(temp,card2);
		end else
		begin
			enqueue(temp,card2);
			enqueue(temp,card1);
		end;
		
		
		{Compare cards}
		if card1 > card2 then
		begin
			{Player 1 wins round}
			player1Success := true;
		end else if card2 > card1 then
		begin
			{Player 2 wins round}
		end else
		begin
			{Tie}
			{Find number of cards in each player's hand}
			player1Length := getLength(player1);
			player2Length := getLength(player2);
			
			if (player1Length > 3) AND (player2Length > 3) then
			begin
				{Play normal tie procedure (3 cards down, go back to beginning and compare the fourth card)}
				
				{Skip rewards section and go to beginning to compare cards after laying 3 down}
				tie := true;
				
				{Collect 3 cards from each player for tie}
				index := 1;
				repeat
					enqueue(temp,dequeue(player1));
					enqueue(temp,dequeue(player2));
					index:=index + 1;
				until index>3;
				{Go back to beginning of game and compare cards}
			end else
			begin
				{One player has less that 4 cards left}
				
				{Find player with least cards}
				if player1Length < player2Length then
				begin
					{Player 1 has least cards (lay down all but one)}
					index:=1;
					playerLength := getLength(player1);
					if index < playerLength then
					begin
						repeat
							enqueue(temp,dequeue(player1));
							enqueue(temp,dequeue(player2));
							index:=index + 1;
						until index=playerLength;
					end;
					
					{Only pull another card of Player 1 has another}
					if getLength(player1) > 0 then
					begin
						card1 := dequeue(player1);
						enqueue(temp,card1);
					end;
					
					{Player 2 lays down a card}
					card2 := dequeue(player2);
					
					if card1 > card2 then
					begin
						{Player 1 wins round}
						enqueue(player1,card2);
						player1Success := true;
					end else if card2 > card1 then
					begin
						{Player 2 wins round (and game)}
						enqueue(player2,card2);
					end else
					begin
						{Tie (Player 2 will keep comparing cards to Player 1's card until either player wins)}
						{Player 2 gets card back from tie}
						enqueue(player2,card2);
						
						{Reinitialize done variable which tells whether a tie round has completed}
						done := false;
						
						{Continue comparing cards until one player beats the other (or a tie game is reached)}
						repeat
							{Card 2 might change over several iterations (but card 1 will not since it is Player 1's only remaining card)}
							
							card2:=dequeue(player2);
							
							if card1 > card2 then
							begin
								{Player 1 wins round}
								done := true;
								
								{Award card to Player 1}
								enqueue(player1,card2);
								player1Success := true;
							end else if card2 > card1 then
							begin
								{Player 2 wins (Game over)}
								done := true;
								
								{Award card to Player 2}
								enqueue(player2,card2);
							end else
							begin
								{Tie}
								{Check for very rare condition that both players tied every round}
								if (getLength(player1)=0) AND (getLength(player2)=0) then
								begin
									{Game Over; Tie Game}
									done:=true;
									trueTie:= true;
								end else
								begin
									{Player 2 gets card back; Go back to beginning of loop and compare new card }
									enqueue(player2,card2);
								end;
							end; {end else}
							
						until done=true;
						
					end; {end else}
					
				end else
				begin
					{Player 2 has least cards (or possibly true tie)}
					{Lay down all cards but one}
					index:=1;
					playerLength := getLength(player2);
					if index < playerLength then
					begin
						repeat
							enqueue(temp,dequeue(player1));
							enqueue(temp,dequeue(player2));
							index:=index + 1;
						until index = playerLength;
					end;
					
					{Only pull another card of Player 2 has another}
					if getLength(player2) > 0 then
					begin
						card2 := dequeue(player2);
						enqueue(temp,card2);
					end;
					
					{Player 1 lays down a card}
					card1 := dequeue(player1);
					
					
					if card1 > card2 then
					begin
						{Player 1 wins round (and game)}
						enqueue(player1,card1);
						player1Success := true;
					end else if card2 > card1 then
					begin
						{Player 2 wins round}
						enqueue(player2,card1);
					end else
					begin
						{Tie (Player 1 will keep comparing cards to Player 2's card until either player wins)}
						{Player 1 gets card back from tie}
						enqueue(player1,card1);
						
						{Reinitialize done variable which tells whether a tie round has completed}
						done := false;
						
						{Continue comparing cards until one player beats the other (or a tie game is reached)}
						repeat
							{Card 1 might change over several iterations (but card 2 will not since it is Player 2's only remaining card)}
						
							card1:=dequeue(player1);
							
							if card1 > card2 then
							begin
								{Player 1 wins round (and game)}
								done := true;
								
								{Award card to Player 1}
								enqueue(player1,card1);
								player1Success := true;
							end else if card2 > card1 then
							begin
								{Player 2 wins}
								done := true;
								
								{Award card to Player 2}
								enqueue(player2,card1);
							end else
							begin
								{Tie}
								{Check for very rare condition that both players tied every round}
								if (getLength(player1)=0) AND (getLength(player2)=0) then
								begin
									{Game Over; Tie Game}
									done:=true;
									trueTie:= true;
								end else
								begin
									{Player 1 gets card back; Go back to beginning of loop and compare new card }
									enqueue(player1,card1);
								end;
							end; {end else}
							
						until done=true;
						
					end; {end else}
				end;
						
			end; {end else (tie)}
		end; {end else (compare cards/round)}
		
		{Reward Area}
		
		{Check for a tie (hold off rewards if tie is true)}
		if not tie AND not trueTie then
		begin
			if player1Success=true then
			begin
				{Award player 1 pending cards}
				index:=1;
				playerlength := getLength(temp);
				repeat
					enqueue(player1,dequeue(temp));
					index:=index + 1;
				until index>playerLength;
			end else
			begin
				{Award Player 2 pending cards}
				index:=1;
				playerLength := getLength(temp);
				repeat
					enqueue(player2,dequeue(temp));
					index:=index + 1;
				until index>playerLength;
			end;
		end; {end Rewards}
		
		{End round}
	
	until (getLength(player1)=0) OR (getLength(player1)=52) OR trueTie;	{End Game}
	
	
	{Determine longest game}
	if longestGame < numRounds then
	begin
		longestGame := numRounds;
	end;
	
	{Determine shortest game}
	if (shortestGame = 0) OR (shortestGame > numRounds) then
	begin
		shortestGame := numRounds;
	end;
	
	{Determine winner}
	if trueTie then
	begin
		winner := 'Tie';
	end else if getLength(player1) > 0 then
	begin
		winner := getName(player1);
	end else
	begin
		winner:= getName(player2);
	end;
	
	
	{Determine wins with specific hands}
	if trueTie then
	begin
		tieGames := tieGames + 1;
	end else
	begin
		if winner=highSum then
		begin
			highSumWins := highSumWins + 1;
		end;
		
		if winner=mostAces then
		begin
			mostAcesWins := mostAcesWins + 1;
		end;
		
		if winner=mostKings then
		begin
			mostKingsWins := mostKingsWins + 1;
		end;
		
		if winner=mostQueens then
		begin
			mostQueensWins := mostQueensWins + 1;
		end;
		
		if winner=mostJacks then
		begin
			mostJacksWins := mostJacksWins + 1;
		end;
		
		if winner=mostTens then
		begin
			mostTensWins := mostTensWins + 1;
		end;
		
	end;
	
	{Increment total number of rounds for each game}
	totalRounds := totalRounds + numRounds;
	
	{Increment number of games played}
	gameNum:= gameNum + 1;
	
	destroy(player1);	{free up memory from queues}
	destroy(player2);	{free up memory from queues}
	destroy(temp);	{free up memory from queues}
	
	{Print number of games played after every 10,000 games}
	if (gameNum MOD 10000 = 0) then
	begin
		writeln(gameNum, ' games played...');
	end;
	
until gameNum > gamesToPlay; {end gamesToPlay (All Games)}

{convert gamesToPlay to double}
tempDouble := gamesToPlay;
EndTime := MemL[$40:$6C];
writeln();
writeln('The game took ',Round((EndTime-StartTime)/18.2),' seconds to complete.');
writeln();
writeln('****************** Results ******************');
writeln('The shortest game length was: ', shortestGame, ' rounds.');
writeln('The longest game length was: ', longestGame, ' rounds.');
writeln('The average game length was: ', (totalRounds/tempDouble):0:2, ' rounds.');
writeln('The person with the highest sum won ', ((highSumWins/tempDouble)*100):0:2, '% of the time');
writeln('The person with the most Aces won ', ((mostAcesWins/tempDouble)*100):0:2, '% of the time');
writeln('The person with the most Kings won ', ((mostKingsWins/tempDouble)*100):0:2, '% of the time');
writeln('The person with the most Queens won ', ((mostQueensWins/tempDouble)*100):0:2, '% of the time');
writeln('The person with the most Jacks won ', ((mostJacksWins/tempDouble)*100):0:2, '% of the time');
writeln('The person with the most Tens won ', ((mostTensWins/tempDouble)*100):0:2, '% of the time');
writeln('There were ', tieGames,' tie games');


writeln;
writeln;
writeln('Press <Enter> To Quit');
readln;
end.	{end Main}
