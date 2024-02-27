# Explication

Ces fichiers sont nécéssaires pour bien faire tourner les 3 modèles en une seule fois, sans devoir déplacer des fichiers, sans devoir renommer ou préciser les fichiers dans les fonctions, et tout çà pour les racines latérales ET tap en même temps, ce qui sauve beaucoup de temps.

Ci-dessous une explication plus précise pour chaque modèle.

# GRANAR

J'ai dupliqué la fonction *aer_in_geom_xml.R* en *aer_in_geom_xml_lat.R*. La seule différence étant le fichier ciblé à l'intérieur de la fonction. Notez que vous devez créér un fichier *Maize_Geometry_lat.xml* et un fichier *Maize_Geometry_lat_aer.xml* dans 'MECHA/Projects/Granar/in/' en précisant dans ce fichier le value pour current_root tandis que *Maize_Geometry.xml* et *Maize_Geometry_aer.xml* précisent current_root_tap. Félicitations, vous pouvez maintenant run lat et tap sans devoir modifier à la main tous les noms de fichiers. Dans le fichier .rmd de granar, cette fonction est appliquée à la ligne 100-106. Notez aussi que vous devez lancer une simulation différente pour chaque anatomie (tap et lat : sim et sim1).

Attention !! Je considère mes racines avec une proportion d'aerenchyme = 0, je me suis permis de modifier la fonction *aer_in_geom_xml.R* et *aer_in_geom_xml_lat.R* en enlevant : 'paste('aerenchyme id', range, '')'. Ceci permet une suppression d'aerenchyme et fait en sorte que Mecha fonctionne convenablement.

# MECHA

Ici également, j'ai dupliqué la fonction mecha() en mecha2() qui lit le fichier *Maize_Geometry_lat_aer.xml*. Pour ce qui est de la lecture de la fonction mecha() et mecha2(), utilisez le fichier *Run_MECHA.ipynb*. Dedans, un fichier .txt sera créé dans le directory lu par MARSHAL. Félicitations, vous avez maintenant lié Granar à Mecha et Mecha à Marshal.

# MARSHAL

La lecture des sorties Mecha se fait ici, j'ai séléctionné les chiffres et je modifie les conductivités originales pour obtenir un .csv qui comprend les nouvelles valeurs Kr de Mecha. Bravo à vous. Le lien entre les modèles est fait, il manque plus qu'à appliquer votre théorie/méthode et modifications des variables qui vous intéressent !

# Questions ?

N'hésitez pas à me contacter si vous avez des questions ! Bonne chance pour le reste du travail :D