using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {
            // Variables 
            string user_choice = "";
            int rand_number;
            string bot_choice;
            int max_points = 0;
            int bot_score = 0;
            int user_score = 0;


            // Max points

            Console.Write("Do ilu chcesz grać? ");
            max_points = int.Parse(Console.ReadLine());


            while (user_choice != "E" & (user_score != max_points & bot_score != max_points))
            {

                // User move

                Console.Write("Wybierz kamień [K], papier [P], nożyczki [N] lub wyjście z gry [E]: ");
                user_choice = Console.ReadLine();
                Console.WriteLine();



                // Bot move 

                Random r = new Random();

                rand_number = r.Next(1, 4);

                // Assigning move to rand_number: 1-KAMIEŃ; 2-PAPIER; 3-NOŻYCZKI

                if (rand_number == 1)
                {
                    bot_choice = "K";
                }
                else if (rand_number == 2)
                {
                    bot_choice = "P";
                }
                else
                {
                    bot_choice = "N";
                }


                // User move validation

                if (user_choice != "K" & user_choice != "P" & user_choice != "N" & user_choice != "E")
                {
                    Console.WriteLine("Co ty w knefel trafić nie umiesz?");
                }
                else if (user_choice == "E")
                {
                    Console.WriteLine("Przerwałeś grę");
                    Console.ReadLine();
                }
                else
                {




                    // Evaluating the result

                    if (user_choice == "K" & bot_choice == "K")
                    {
                        Console.WriteLine("Komputer też wybrał KAMIEŃ, ta runda na REMIS. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "K" & bot_choice == "P")
                    {
                        bot_score = bot_score + 1;
                        Console.WriteLine("Komputer wybrał PAPIER, PRZEGRAŁEŚ rundę. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "K" & bot_choice == "N")
                    {
                        user_score = user_score + 1;
                        Console.WriteLine("Komputer wybrał NOŻYCZKI, WYGRYWASZ rundę. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "P" & bot_choice == "K")
                    {
                        user_score = user_score + 1;
                        Console.WriteLine("Komputer wybrał KAMIEŃ, WYGRYWASZ rundę. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "P" & bot_choice == "P")
                    {
                        Console.WriteLine("Komputer też wybrał PAPIER, ta runda na REMIS. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "P" & bot_choice == "N")
                    {
                        bot_score = bot_score + 1;
                        Console.WriteLine("Komputer wybrał NOŻYCZKI, PRZEGRAŁEŚ rundę. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "N" & bot_choice == "K")
                    {
                        bot_score = bot_score + 1;
                        Console.WriteLine("Komputer wybrał KAMIEŃ, PRZEGRAŁEŚ rundę. Wynik " + user_score + ":" + bot_score); 
                        Console.WriteLine();
                    }
                    else if (user_choice == "N" & bot_choice == "P")
                    {
                        user_score = user_score + 1;
                        Console.WriteLine("Komputer wybrał PAPIER, WYGRYWASZ rundę. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }
                    else if (user_choice == "N" & bot_choice == "N")
                    {
                        Console.WriteLine("Komputer wybrał NOŻYCZKI, ta runda na REMIS. Wynik " + user_score + ":" + bot_score);
                        Console.WriteLine();
                    }


                }

            }

            if (user_choice != "E")
            {
                if (user_score > bot_score)
                {
                    Console.WriteLine("Wygrałeś szpil, BRAWO!!!");
                    Console.ReadLine();
                }
                else if (user_score < bot_score)
                {
                    Console.WriteLine("PRZEGRAŁEŚ szpil");
                    Console.ReadLine();
                }
            }

        }
    }
}


