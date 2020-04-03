var start_button=document.querySelector("#start_game");
var code_roll=document.querySelector("#id_bankroll");
var decision_panel=document.querySelector("#decision_panel");
var header_player_name=document.querySelector("#player_points_header");
var bet_button=document.querySelector("#id_bet_button");
var take_card_button=document.querySelector("#id_take_card");
var wait_button=document.querySelector("#id_wait");
var bet_amount=document.querySelector("#id_bet");
var player_img_list=document.querySelectorAll(".user_card");
var dealer_img_list=document.querySelectorAll(".dealer_card");
var dealer_card_hand=[];
var user_card_hand=[];
var points_dealer=document.querySelector("#id_dealer_points");
var points_player=document.querySelector("#id_player_points");
var exit=0;
var dealer_win=0;
var new_hand_button=document.querySelector("#id_new_hand");
var bet_error=0;


var card_deck_object={
						"cards_array":["Ah","2h","3h","4h","5h","6h","7h","8h","9h","Th","Jh","Qh","Kh",
									 "Ad","2d","3d","4d","5d","6d","7d","8d","9d","Td","Jd","Qd","Kd"],

						"cards_dict":{"Ah":["https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Playing_card_heart_A.svg/60px-Playing_card_heart_A.svg.png","A"],
									"2h":["https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Playing_card_heart_2.svg/60px-Playing_card_heart_2.svg.png",2],
									"3h":["https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Playing_card_heart_3.svg/60px-Playing_card_heart_3.svg.png",3],
									"4h":["https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Playing_card_heart_4.svg/60px-Playing_card_heart_4.svg.png",4],
									"5h":["https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Playing_card_heart_5.svg/60px-Playing_card_heart_5.svg.png",5],
									"6h":["https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Playing_card_heart_6.svg/60px-Playing_card_heart_6.svg.png",6],
									"7h":["https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Playing_card_heart_7.svg/60px-Playing_card_heart_7.svg.png",7],
									"8h":["https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Playing_card_heart_8.svg/60px-Playing_card_heart_8.svg.png",8],
									"9h":["https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Playing_card_heart_9.svg/60px-Playing_card_heart_9.svg.png",9],
									"Th":["https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Playing_card_heart_10.svg/60px-Playing_card_heart_10.svg.png","T"],
									"Jh":["https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Playing_card_heart_J.svg/60px-Playing_card_heart_J.svg.png","J"],
									"Qh":["https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Playing_card_heart_Q.svg/60px-Playing_card_heart_Q.svg.png","Q"],
									"Kh":["https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Playing_card_heart_K.svg/60px-Playing_card_heart_K.svg.png","K"],
									"Ad":["https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Playing_card_diamond_A.svg/60px-Playing_card_diamond_A.svg.png","A"],
									"2d":["https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Playing_card_diamond_2.svg/60px-Playing_card_diamond_2.svg.png",2],
									"3d":["https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Playing_card_diamond_3.svg/60px-Playing_card_diamond_3.svg.png",3],
									"4d":["https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Playing_card_diamond_4.svg/60px-Playing_card_diamond_4.svg.png",4],
									"5d":["https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Playing_card_diamond_5.svg/60px-Playing_card_diamond_5.svg.png",5],
									"6d":["https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Playing_card_diamond_6.svg/60px-Playing_card_diamond_6.svg.png",6],
									"7d":["https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Playing_card_diamond_7.svg/60px-Playing_card_diamond_7.svg.png",7],
									"8d":["https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Playing_card_diamond_8.svg/60px-Playing_card_diamond_8.svg.png",8],
									"9d":["https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Playing_card_diamond_9.svg/60px-Playing_card_diamond_9.svg.png",9],
									"Td":["https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Playing_card_diamond_10.svg/60px-Playing_card_diamond_10.svg.png","T"],
									"Jd":["https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Playing_card_diamond_J.svg/60px-Playing_card_diamond_J.svg.png","J"],
									"Qd":["https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Playing_card_diamond_Q.svg/60px-Playing_card_diamond_Q.svg.png","Q"],
									"Kd":["https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Playing_card_diamond_K.svg/60px-Playing_card_diamond_K.svg.png","K"]
									},
						
						take_card_method:function(){
							var random_index=Math.floor(Math.random()*this.cards_array.length);
							taken_card=this.cards_dict[this.cards_array[random_index]];
							this.cards_array.splice(random_index,1);
							return taken_card;
						},
						
						resetDeck:function(){
							this.cards_array=["Ah","2h","3h","4h","5h","6h","7h","8h","9h","Th","Jh","Qh","Kh",
						"Ad","2d","3d","4d","5d","6d","7d","8d","9d","Td","Jd","Qd","Kd"]}
};



function sleep(milliseconds) { 
    let timeStart = new Date().getTime(); 
    while (true) { 
      let elapsedTime = new Date().getTime() - timeStart; 
      if (elapsedTime > milliseconds) { 
        break; 
      } 
    } 
  } 

				

function decreaseRoll(){
	bet_size=parseInt(bet_amount.value);
	if(bet_size<=0 || bet_amount.value==""){
		alert("Panie, wypadałoby zagrać za więcej niż 0");
		bet_error=1;
	}
	if(bet_size>0 && bet_amount.value!=""){
		if(parseInt(code_roll.textContent)-bet_size>=0){
			code_roll.textContent=parseInt(code_roll.textContent)-bet_size;
			bet_error=0;
		}else{
			alert("Nie masz wystarczająco siana, żeby tak zagrać");
			bet_error=1;
		}
	}
	
}

function increaseRoll(){
	bet_size=parseInt(bet_amount.value);
	return parseInt(code_roll.textContent)+2*bet_size;
}

function calculatePoints(card_vector){
	var suma=0;
	for(var i=0;i<card_vector.length;i++){
		if(card_vector[i]=="J" || card_vector[i]=="Q" ||card_vector[i]=="K" ||card_vector[i]=="T"){
			suma=suma+10;
		}else if(card_vector[i]!="A"){
			suma=suma+card_vector[i]
		}
	}
		return suma;
}

function checkBusted(score){
		if(parseInt(score)>21){
			return true;
		}else{
			return false;
		}
}



function checkDealerWin(dealer_score,player_score){
	if(dealer_score<=21 && dealer_score>player_score){
			return true;
		}
};


function checkDraw(dealer_score,player_score){
	if(
		(dealer_score==18 && player_score==18) ||
		(dealer_score==19 && player_score==19) ||
		(dealer_score==20 && player_score==20) ||
		(dealer_score==21 && player_score==21)
	){
		return true;
	}else{
		return false;
	}
};

function checkZero(){
	if(parseInt(code_roll.textContent)==0){
		return true;
	}else{
		return false;
	}
};


function resetBoard(){
	for(var i=0;i<player_img_list.length;i++){
		player_img_list[i].setAttribute("src","")
	}
	for(var i=0;i<dealer_img_list.length;i++){
		dealer_img_list[i].setAttribute("src","");
	}	
}



start_button.addEventListener("click",function(){
	resetBoard();
	card_deck_object.resetDeck();
	bet_amount.disabled=false;
	bet_amount.value="";
	bet_button.disabled=false;
	points_dealer.textContent="";
	points_player.textContent="";	
	user_card_hand=[];
	dealer_card_hand=[];
	alert("Kłaniamy się nisko w kolejnej partii BLACKJACKA")
	var user_name=prompt("Podaj imię");
	var user_roll=parseInt(prompt("Wprowadź, iloma żetonami chcesz grać"));
	code_roll.textContent=user_roll;	
	decision_panel.style.display="block";
	header_player_name.textContent=user_name;
	}
)

bet_button.addEventListener("click",function(){
	decreaseRoll();
	if(bet_error==0){
		bet_button.disabled=true;
		take_card_button.disabled=false;
		wait_button.disabled=false;
		bet_amount.disabled=true; 
		// Losuj kartę dla dealera
		var dealer_random_card=card_deck_object.take_card_method();
		var dealer_card_link=dealer_random_card[0];
		dealer_card_hand.push(dealer_random_card[1]);
		for(var i=0;i<dealer_img_list.length;i++){
			if(dealer_img_list[i].getAttribute("src")==""){
				dealer_img_list[i].setAttribute("src",dealer_card_link);
				break;
			}
		}
		// Losuj karty dla gracza
		for(var l=0;l<2;l++){
			var player_random_card=card_deck_object.take_card_method();
			var player_card_link=player_random_card[0];
			user_card_hand.push(player_random_card[1]);
			for(var i=0;i<player_img_list.length;i++){
				if(player_img_list[i].getAttribute("src")==""){
					player_img_list[i].setAttribute("src",player_card_link);
					break;
				}
			}	
		}
		// Oblicz punkty 
		points_dealer.textContent=calculatePoints(dealer_card_hand);
		points_player.textContent=calculatePoints(user_card_hand);
	}
});
			

// Dobierz kartę
take_card_button.addEventListener("click",function(){
	//Losuj kartę dla gracza
	var player_random_card=card_deck_object.take_card_method();
	var player_card_link=player_random_card[0];
	user_card_hand.push(player_random_card[1]);
	for(var i=0;i<player_img_list.length;i++){
		if(player_img_list[i].getAttribute("src")==""){
			player_img_list[i].setAttribute("src",player_card_link);
			break;
		}
	}
	// Oblicz punkty 
	points_player.textContent=calculatePoints(user_card_hand);
	// Sprawdź czy busto
	if(checkBusted(points_player.textContent)){
		alert("Spaliłeś");
		if(checkZero()){
			alert("No i torba. Pozdro & poćwicz");
			new_hand_button.disabled=true;
			take_card_button.disabled=true;
			wait_button.disabled=true;
		}else{
			new_hand_button.disabled=false;
			take_card_button.disabled=true;
			wait_button.disabled=true;	
		}
	}
});										
			

// Czekaj 
wait_button.addEventListener("click",function(){
	take_card_button.disabled=true;
	wait_button.disabled=true;
	//Losuj kartę dla dealera - interwały, while punkty <18
	while(parseInt(points_dealer.textContent)<21 && parseInt(points_dealer.textContent)<parseInt(points_player.textContent)){
		var dealer_random_card=card_deck_object.take_card_method();
		var dealer_card_link=dealer_random_card[0];
		dealer_card_hand.push(dealer_random_card[1]);
		for(var i=0;i<dealer_img_list.length;i++){
			if(dealer_img_list[i].getAttribute("src")==""){
				dealer_img_list[i].setAttribute("src",dealer_card_link);
				break;
			}
		}
		// Oblicz punkty 
		points_dealer.textContent=calculatePoints(dealer_card_hand);
		//Sprawdź czy busto 
		if(checkBusted(points_dealer.textContent)){
			alert("Dealer spalił - wygrywasz rundę");
			new_hand_button.disabled=false;
			take_card_button.disabled=true;
			wait_button.disabled=true;
			//Wypłać wygraną
			code_roll.textContent=increaseRoll();		
		}
		
		//Check draw
		if(checkDraw(parseInt(points_dealer.textContent),parseInt(points_player.textContent))){
			alert("Runda zakończona remisem");
			new_hand_button.disabled=false;
			code_roll.textContent=parseInt(code_roll.textContent)+parseInt(bet_amount.value);
			take_card_button.disabled=true;
			wait_button.disabled=true;		
			break;
		}
		
		// Check win
		if(checkDealerWin(parseInt(points_dealer.textContent),parseInt(points_player.textContent))){
			alert("Przegrywasz rundę");
			if(checkZero()){
				alert("No i torba. Pozdro & poćwicz");
				new_hand_button.disabled=true;
				take_card_button.disabled=true;
				wait_button.disabled=true;
				break;
			}else{
				new_hand_button.disabled=false;
				take_card_button.disabled=true;
				wait_button.disabled=true;	
				break;
			}
		}
	}
	
});


// Nowe rozdanie 
new_hand_button.addEventListener("click",function(){
	resetBoard();
	card_deck_object.resetDeck();
	bet_amount.disabled=false;
	bet_amount.value="";
	bet_button.disabled=false;
	points_dealer.textContent="";
	points_player.textContent="";	
	user_card_hand=[];
	dealer_card_hand=[];
});
