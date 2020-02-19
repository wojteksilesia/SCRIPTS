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
            double n_s = 10000000;

            double zero = 0;
            double jedynka = 0;
            double dwojka = 0;
            double trojka = 0;
            double czworka = 0;
            double piatka = 0;
            double szostka = 0;

            for (int i = 1; i <= n_s; i++)
            {


                int[] wybrane_liczby = { 1, 2, 3, 4, 5, 6 };
                int[] wylosowane_liczby = new int[6];
                int trefione = 0;

                


                wylosowane_liczby = Losuj_liczby(6);

                trefione = Lotto_Trefione(wybrane_liczby, wylosowane_liczby);

                if (trefione == 0)
                {
                    zero = zero + 1;
                } else if (trefione == 1)
                {
                    jedynka = jedynka + 1;
                } else if (trefione == 2)
                {
                    dwojka = dwojka + 1;
                } else if (trefione == 3)
                {
                    trojka = trojka + 1;
                } else if (trefione == 4)
                {
                    czworka = czworka + 1;
                } else if (trefione == 5)
                {
                    piatka = piatka + 1;
                } else if (trefione == 6)
                {
                    szostka = szostka + 1;
                }
            }

            Console.WriteLine("0: " + zero / n_s);
            Console.WriteLine("1: " + jedynka / n_s);
            Console.WriteLine("2: " + dwojka / n_s);
            Console.WriteLine("3: " + trojka / n_s);
            Console.WriteLine("4: " + czworka / n_s);
            Console.WriteLine("5: " + piatka / n_s);
            Console.WriteLine("6: " + szostka / n_s);





        }

        static int Lotto_Trefione(int[] wybrane, int[] wylosowane)
        {
            int ile_trafionych = 0;

            for (int i = 0; i <= 5; i++)
            {
                for (int j = 0; j <= 5; j++)
                {
                    if (wybrane[i] == wylosowane[j])
                    {
                        ile_trafionych = ile_trafionych + 1;
                    }
                }
            }
            return ile_trafionych;
        }

        static int[] Losuj_liczby(int n)
        {
            int[] wylosowane = new int[n];
            int powtorki;

            Random r = new Random();


            for (int i = 0; i <= n - 1; i++)
            {
                powtorki = 0;
                while (powtorki < i | (i==0 & powtorki==0))
                {

               
                wylosowane[i] = r.Next(1, 50);



                    for (int j = 0; j <= i; j++)
                    {
                        if (i != j & wylosowane[i] == wylosowane[j])
                        {
                            powtorki = powtorki + 0;
                        } else if(i!=j & wylosowane[i] != wylosowane[j])
                        {
                            powtorki = powtorki + 1;
                        }else if (i == 0)
                        {
                            powtorki = powtorki + 1;
                        }
                    }
                }
                
            }

            return wylosowane;


        }
    }
}

