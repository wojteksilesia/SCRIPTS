// 1) Kliknięcie na URUCHOM NOWĄ GRĘ - prośba o imię użytkownika, ustawienie imienia w polu "GRACZ" 
// 2) Stworzenie obiektu, w którym klucz=1-6, wartość=link do kostki 
//3) Funkcja, która przyjmuje argument czyj jest ruch


var v_start_button = document.querySelector("#id_start");
var v_id_player_name = document.querySelector("#id_player_name");
var v_id_bot_name = document.querySelector("#id_bot_name");

var dice_object={1:"http://www.clker.com/cliparts/X/w/P/Y/q/H/dice-1-md.png", 2:"http://www.clker.com/cliparts/X/V/S/C/I/x/dice-2-md.png", 
				 3:"http://www.clker.com/cliparts/8/u/t/L/K/e/dice-3-md.png",4:"http://www.clker.com/cliparts/D/j/Z/R/5/P/dice-4-md.png",
				 5:"http://www.clker.com/cliparts/U/N/J/F/T/x/dice-5-md.png",6: "https://cdn.clipart.email/5b7f7542a54a81fb00ffb917a29a8f6d_clipart-dado-6_2446-2400.png"
				};

var move=0; // 0-player; 1-bot 
var player_picture = document.querySelector("#id_player_dice");
var bot_picture = document.querySelector("#id_bot_dice");
var kulej_button = document.querySelector("#id_kulej");


var player_sum=0;
var bot_sum=0;

var player_score=0;
var bot_score=0;

var player_points_field = document.querySelector("#id_player_points");
var bot_points_field = document.querySelector("#id_bot_points");



v_start_button.addEventListener("click",function(){
	var v_player_name=prompt("Witaj randomie w grze w kulanie! Podaj imię");
	v_id_player_name.textContent=v_player_name;
	
	player_sum=0;
	bot_sum=0;
	
	player_points_field.textContent=player_sum;
	bot_points_field.textContent=bot_sum;

});

function random_round(whose_move){
	
	//Powtarzaj losowanie 10 razy, żeby kostka fajnie się kulała
	for(var i=0;i<1000;i++){
		
		//Losuj randomową liczbę 1-6
		var random_number=Math.ceil(Math.random()*6);
	
		//Weź obraz kostki
		var dice_number_link=dice_object[random_number];
		
		//W zależności od tego czyj ruch, zmień kostkę
		if(whose_move==0){
			player_picture.setAttribute("src",dice_number_link);
			player_score=random_number;
		}else if(whose_move==1){
			bot_picture.setAttribute("src",dice_number_link);
			bot_score=random_number;
		}
	}		
}

function check_win(in_player_score,in_bot_score){
	if(in_player_score>in_bot_score){
		player_sum=player_sum+1;
	}else if(in_player_score<in_bot_score){
		bot_sum=bot_sum+1
	}
	player_points_field.textContent=player_sum;
	bot_points_field.textContent=bot_sum;
}


kulej_button.addEventListener("click",function(){
	random_round(move);
	if(move==0){
		move=1;
		v_id_player_name.style.color="black";
		v_id_bot_name.style.color="red";
	}else{
		move=0;
		v_id_player_name.style.color="red";
		v_id_bot_name.style.color="black";
		check_win(player_score,bot_score);
	}
	
});

	
	