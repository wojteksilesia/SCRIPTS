random_repertoire<-function(){
  
  for_white <- c("1.d4","Jobava-Rapport London","Colle & Barry & 150","1.Sf3","1.g3","1.c4 Iron Botvinnik",
                 "1.b3","1.Sc3","1.e4")
  prob_for_white<-c(40,14,5,13,13,5,5,2,3)
  
  qgd_white <- c("Catalan", "Exchanged")
  prob_qgd_white <- c(50,50)
  
  slav_white_1d4 <- c("4.Sc3","4.e3")
  prob_slav_white_1d4 <- c(50,50)
  
  nimzo_white<-c("4.e3","4.f3")
  prob_nimzo_white<-c(50,50)
  
  kid_white <- c("Averbakh","Saemisch","Classical - Bayonet", "Classical - Gligoric")
  prob_kid_white <- c(60,20,10,10)
  
  benko_white <- c("f3","Sf3 & b6")
  prob_benko_white <- c(30,70)
  
  
  nf3_d5_white <- c("Delchev anti slav","Wojo & Donaldson & Hansen repertoire - catalan, 4.Qc2 vs Slav")
  prob_nf3_d5_white <- c(60,40)
  
  ##############
  
  e4_black <- c("French","Sniper","Caro-Kann","Sicilian","Black Lion ...Nf8","Black Lion ...ed4 Be7")
  prob_e4_black <- c(80,5,5,5,2.5,2.5)
  
  against_Nc3_Nd2 <- c("Classic","Rubinstein")
  prob_against_Nc3_Nd2 <- c(65,35)
  
  Nd2_black <- c("3...Sf6","3...c5")
  prob_Nd2_black <- c(40,60)
  
  Nc3_black <- c("3...Sf6","3...Gb4")
  prob_Nc3_black <- c(50,50)
  
  rubinstein_black<-c("4...Nd7","4...Bd7")
  prob_rubinstein_black<-c(35,65)
  
  sicilians_black <- c("Accelerated Dragon","Scheveningen","Sveshnikov")
  prob_sicilians_black <- c(34,33,33)
  
  #############
  
  d4_black <- c("Stonewall","Rapport stonewall","QGD","Slav","Classical Dutch","Leningrad Dutch","Keres-Baltic")
  prob_d4_black<- c(27,13,40,10,4,4,2)
  
  c4_black <- c("1...e6 QGD","Classical Dutch","Symmetrical ...Bf5")
  prob_c4_black <- c(50,35,15)
  
  nf3_black <- c("1...d5 QGD","Classical Dutch")
  prob_nf3_black <- c(65,35)
  
  ################
  
  random_opening <- function(in_openings,in_probs){
    return(sample(in_openings,1,prob=in_probs/100))
  }
  
  ##############
  
  ### For white
  play_white <- random_opening(for_white,prob_for_white)
  
  message_white<-paste0("<b>WHITE:</b>"," ",play_white)
  
  if(play_white=="1.d4"){
    vs_qgd<-random_opening(qgd_white,prob_qgd_white)
    vs_slav<-random_opening(slav_white_1d4,prob_slav_white_1d4)
    vs_nimzo<-random_opening(nimzo_white,prob_nimzo_white)
    vs_kid<-random_opening(kid_white,prob_kid_white)
    vs_benko<-random_opening(benko_white,prob_benko_white)
    
    message_white<-paste0(message_white,
                          "<p>Against QGD: ",vs_qgd,"</p>",
                          "<p>Against Slav: ",vs_slav,"</p>",
                          "<p>Against Nimzo: ",vs_nimzo,"</p>",
                          "<p>Against King's-Indian: ",vs_kid,"</p>",
                          "<p>Against Benko: ",vs_benko,"</p>"
                          )
    
  }else if(play_white=="1.Sf3"){
    more_Nf3<-random_opening(nf3_d5_white,prob_nf3_d5_white)
    
    message_white<-paste0(message_white,"<p>",more_Nf3,"</p>")
  }
  
  #print(message_white)
  
  ####### Black vs 1.e4
  play_vs_e4<-random_opening(e4_black,prob_e4_black)
  
  message_black_e4<-paste0("<b>BLACK vs 1.e4:</b>"," ",play_vs_e4)
  
  if(play_vs_e4=="French"){
    play_vs_nc3d2_french<-random_opening(against_Nc3_Nd2,prob_against_Nc3_Nd2)
    if(play_vs_nc3d2_french=="Classic"){
      play_vs_f_Nc3<-random_opening(Nc3_black,prob_Nc3_black)
      play_vs_f_Nd2<-random_opening(Nd2_black,prob_Nd2_black)
      message_black_e4<-paste0(message_black_e4,
                               "<p>Against 3.Nc3: ",play_vs_f_Nc3,"</p>",
                               "<p>Against 3.Nd2: ",play_vs_f_Nd2,"</p>"
                               )
    }else if(play_vs_nc3d2_french=="Rubinstein"){
      rubi_line<-random_opening(rubinstein_black,prob_rubinstein_black)
      message_black_e4<-paste0(message_black_e4,
                               "<p>Against 3.Nc3/Nd2: Rubinstein ",rubi_line,"</p>"
                               )
    }
  }else if(play_vs_e4=="Sicilian"){
    rand_sycyl<-random_opening(sicilians_black,prob_sicilians_black)
    message_black_e4<-paste0(message_black_e4," ","<b>",rand_sycyl,"</b>")
  }
  
  #print(message_black_e4)
  
  #### Black vs 1.d4
  play_vs_d4<-random_opening(d4_black,prob_d4_black)
  message_black_d4<-paste0("<b>BLACK vs 1.d4:</b>"," ",play_vs_d4)
  
  ### Black vs 1.c4
  play_vs_c4<-random_opening(c4_black,prob_c4_black)
  message_black_c4<-paste0("<b>BLACK vs 1.c4:</b>"," ",play_vs_c4)
  
  ### Black vs 1.Nf3
  play_vs_nf3<-random_opening(nf3_black,prob_nf3_black)
  message_black_nf3<-paste0("<b>BLACK vs 1.Nf3:</b>"," ",play_vs_nf3)
  
  out_message<-paste0("<p>",message_white,"</p>",
                      "<br><p>",message_black_e4,"</p>",
                      "<br><p>",message_black_d4,"</p>",
                      "<br><p>",message_black_c4,"</p>",
                      "<br><p>",message_black_nf3,"</p>")
  
  return(out_message)
}
