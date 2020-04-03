var player_1_name=prompt("Siemano graczu 1, podaj imię");
var player_2_name=prompt("Siemano graczu 2, podaj imię");
var info_1='<span id="col-pl-1">'+player_1_name+' '+ '</span>TWÓJ RUCH, WYBIERZ KOLUMNĘ, BY ZRZUCIĆ SWÓJ NIEBIESKI KLOCEK';
var info_2='<span id="col-pl-2">'+player_2_name+' '+ '</span>TWÓJ RUCH, WYBIERZ KOLUMNĘ, BY ZRZUCIĆ SWÓJ CZERWONY KLOCEK';

$("h3").html(info_1);

$("#id_play_again").click(function(){
	window.location.reload()
});


// $(".column_1").eq(0).css("background-color","blue")

var column_1_array = $(".column_1");
var column_2_array = $(".column_2");
var column_3_array = $(".column_3");
var column_4_array = $(".column_4");
var column_5_array = $(".column_5");
var column_6_array = $(".column_6");
var column_7_array = $(".column_7");

var turn=1; // 1-ruch gracza 1 (niebieskiego), 2-ruch gracza 2 (czerwonego)

var move_matrix=[
				  [0,0,0,0,0,0,0],
				  [0,0,0,0,0,0,0],
				  [0,0,0,0,0,0,0],
				  [0,0,0,0,0,0,0],
				  [0,0,0,0,0,0,0],
				  [0,0,0,0,0,0,0]
				]
				
var already_end=0;

//////////////////////////////

function save_move(row_index,col_index,id_player){
	move_matrix[row_index][col_index]=id_player;
}

/////////////////////////////

function checkDraw(inMatrix){
	for(var row=0;row<inMatrix.length;row++){
		for(var col=0;col<inMatrix[0].length;col++){
			if(inMatrix[row][col]==0){
				return false;
			}
		}
	}
	return true;
}



/////////////////////////////
function checkWin(inMatrix,idPlayer){
	for(var row=0;row<inMatrix.length;row++){
		for(var col=0;col<inMatrix[0].length;col++){
			// Horizontal/poziom
			if(col<inMatrix[0].length-3){
				if(inMatrix[row][col]==idPlayer && inMatrix[row][col+1]==idPlayer && inMatrix[row][col+2]==idPlayer && inMatrix[row][col+3]==idPlayer){
					return true;
				}
			}
			// Vertical/pion
			if(row<inMatrix.length-3){
				if(inMatrix[row][col]==idPlayer && inMatrix[row+1][col]==idPlayer && inMatrix[row+2][col]==idPlayer && inMatrix[row+3][col]==idPlayer){
					return true;
				}
			}
			// Diagonal '\'
			if(row<inMatrix.length-3 && col<inMatrix[0].length-3){
				if(inMatrix[row][col]==idPlayer && inMatrix[row+1][col+1]==idPlayer && inMatrix[row+2][col+2]==idPlayer && inMatrix[row+3][col+3]==idPlayer){
					return true;
				}
			}
			// Diagonal '/'
			if(row>inMatrix.length-3 && col<inMatrix[0].length-3){
				if(inMatrix[row][col]==idPlayer && inMatrix[row-1][col+1]==idPlayer && inMatrix[row-2][col+2]==idPlayer && inMatrix[row-3][col+3]==idPlayer){
					return true;
				}
			}			
		}
	}
	return false;
};






////////////////////////////

function drop_piece(column,player_turn,col_index){
			for(var i=0;i<column.length;i++){
			if((column.eq(i+1).css("background-color")!="rgb(128, 128, 128)" || i==(column.length-1)) && column.eq(0).css("background-color")=="rgb(128, 128, 128)") {
				if(player_turn==1 && already_end==0){
					column.eq(i).css("background-color","blue");
					turn=2;
					$("h3").html(info_2);
					save_move(i,col_index,1)
					if(checkDraw(move_matrix)&&already_end==0){ alert("Gra zakończona remisem! Odśwież przeglądarkę, by zagrać ponownie");$("h3").text("GRA ZAKOŃCZONA REMISEM"); already_end=1;};
					if(checkWin(move_matrix,1)&&already_end==0){ alert(player_1_name + " wygrywa szpil!"); $("h3").html('<span id="col-pl-1">'+player_1_name+' '+ '</span>WYGRYWA SZPIL');already_end=1;};
					break;
				}else if(player_turn==2 && already_end==0){
					column.eq(i).css("background-color","red");
					turn=1;
					$("h3").html(info_1);
					save_move(i,col_index,2)
					if(checkDraw(move_matrix)&&already_end==0){ alert("Gra zakończona remisem! Odśwież przeglądarkę, by zagrać ponownie");$("h3").text("GRA ZAKOŃCZONA REMISEM");already_end=1;};
					if(checkWin(move_matrix,2)&&already_end==0){ alert(player_2_name + " wygrywa szpil!"); $("h3").html('<span id="col-pl-2">'+player_2_name+' '+ '</span>WYGRYWA SZPIL');already_end=1;};
					break;					
				}
			}
		}
	};

///////////////////////////////

// function check draw, check win, rejestracja ruchu w macierzy 

$(".column_1").click(function(){
	if(turn==1){
		drop_piece(column_1_array,1,0);
	}else if(turn==2){
		drop_piece(column_1_array,2,0);
	}
});

$(".column_2").click(function(){
	if(turn==1){
		drop_piece(column_2_array,1,1);
	}else if(turn==2){
		drop_piece(column_2_array,2,1);
	}
});

$(".column_3").click(function(){
	if(turn==1){
		drop_piece(column_3_array,1,2);
	}else if(turn==2){
		drop_piece(column_3_array,2,2);
	}
});

$(".column_4").click(function(){
	if(turn==1){
		drop_piece(column_4_array,1,3);
	}else if(turn==2){
		drop_piece(column_4_array,2,3);
	}
});

$(".column_5").click(function(){
	if(turn==1){
		drop_piece(column_5_array,1,4);
	}else if(turn==2){
		drop_piece(column_5_array,2,4);
	}
});

$(".column_6").click(function(){
	if(turn==1){
		drop_piece(column_6_array,1,5);
	}else if(turn==2){
		drop_piece(column_6_array,2,5);
	}
});

$(".column_7").click(function(){
	if(turn==1){
		drop_piece(column_7_array,1,6);
	}else if(turn==2){
		drop_piece(column_7_array,2,6);
	}
});


// $(this).closest("td").index();