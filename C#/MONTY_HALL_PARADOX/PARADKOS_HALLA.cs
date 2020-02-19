using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DotNetApp
{
    

    class Program
    {
        
        static void Main(string[] args)
        {
            Random r = new Random();

            /* Liczba scenariuszy */
            Console.Write("Podaj liczbę scenariuszy: ");
            int n_scenariuszy = int.Parse(Console.ReadLine());

            double zmiana_decyzji = 0;
            double brak_zmiany_decyzji = 0;
            double winning_if_0 = 0;
            double winning_if_1 = 0;

            for (int i = 1; i <= n_scenariuszy; i++)
            {



                /* Gate choosen by the player */
                int player_choice = r.Next(1, 4);

                /* Winning gate */

                int winning_gate = r.Next(1, 4);

                /* Choosing losing gate to open */

                int loosing_gate = 1;

                while (loosing_gate == player_choice | loosing_gate == winning_gate)
                {
                    loosing_gate = r.Next(1, 4);
                }

                /* Change decision? 0 - brak zmiany; 1-zmiana*/

                int decision = r.Next(0, 2);
                int player_final_choice = player_choice;

                

                if (decision == 0)
                {
                    player_final_choice = player_choice;
                    brak_zmiany_decyzji = brak_zmiany_decyzji + 1;
                }
                else if (decision == 1)
                {

                    while (player_final_choice == player_choice | player_final_choice == loosing_gate)
                    {
                        player_final_choice = r.Next(1, 4);
                    }
                    zmiana_decyzji = zmiana_decyzji + 1;
                }

                /* Checking if final player choice is winning choice */

                



                if (decision == 0)
                {
                    if (player_final_choice == winning_gate)
                    {
                        winning_if_0 = winning_if_0 + 1;
                    }
                }
                else if (decision == 1)
                {
                    if (player_final_choice == winning_gate)
                    {
                        winning_if_1 = winning_if_1 + 1;
                    }
                }

            }

            double winrate_zmiana_decyzji = (winning_if_1 / zmiana_decyzji);
            double winrate_brak_zmiany_decyzji = (winning_if_0 / brak_zmiany_decyzji);

            winrate_zmiana_decyzji = Math.Round(winrate_zmiana_decyzji, 3);
            winrate_brak_zmiany_decyzji = Math.Round(winrate_brak_zmiany_decyzji, 3);

          

            Console.WriteLine("n: " + n_scenariuszy);
            Console.WriteLine();
            Console.WriteLine("Zmieniono decyzję: " + zmiana_decyzji + " razy");
            Console.WriteLine();
            Console.WriteLine("Nie zmieniono decyzji: " + brak_zmiany_decyzji + " razy");
            Console.WriteLine();
            Console.WriteLine("Winning rate gdy zmiana decyzji: " + winrate_zmiana_decyzji);
            Console.WriteLine();
            Console.WriteLine("Winning rate gdy brak zmiany decyzji: " + winrate_brak_zmiany_decyzji);
            Console.WriteLine();
            
           
        }
    }
}
