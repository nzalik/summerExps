import csv
from datetime import datetime
import os

def generate_linear_profile(duration, step_size, start_value, end_values):
    """
    Génère un profil de charge linéaire avec la progression donnée.

    Args:
        duration (float): Durée totale du profil de charge (en secondes).
        step_size (float): Taille de chaque étape de la progression.
        start_value (float): Valeur de départ.
        end_value (float): Valeur finale.

    Returns:
        None
    """

    now = datetime.now()
    dir_name = f"profiles_{now.strftime('%Y-%m-%d')}"
    if not os.path.exists(dir_name):
        os.makedirs(dir_name, exist_ok=True)

    for end_value in end_values:
        file_name = f"linear_{end_value}requests_max_per_sec.csv"
        file_path = os.path.join(dir_name, file_name)

        with open(file_path, 'w', newline='') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(['timestamp', 'requests'])

            for t in range(0, int(duration + step_size), int(step_size)):
                if t < (duration - (2 * step_size)):
                    value = start_value + (end_value - start_value) * t / duration
                    if value % 1 != 0:  # Si la valeur n'est pas un entier
                        value = int(value)  # Arrondir au nombre entier le plus proche
                    writer.writerow([t+0.5, value])
                else:
                    # Pendant les 2 derniers paliers, conserver la même valeur finale
                    writer.writerow([t+0.5, int(end_value)])

            print(f"Profil de charge linéaire généré: {file_name}")

# Paramètres de configuration
DURATION = 600.5  # Durée totale du profil de charge (en secondes)
STEP_SIZE = 1.0
START_VALUE = 0.5  # Valeur de départ
#END_VALUE = [30, 40]  # Valeur finale
END_VALUE = [50, 80, 100, 130, 150, 180, 200]  # Valeur finale

generate_linear_profile(DURATION, STEP_SIZE, START_VALUE, END_VALUE)