# Calcul du volume racinaire et du $Z_{SUF}$

### Fonction permettant de calculer le volume racinaire total et le $Z_{SUF}$ d'un système racinaire simulé au préalable avec CRootBox et MARSHAL.

### Auteur : Mara Lurkin

# Préalables
Pour utiliser les deux fonctions présentent dans le document il faut déjà disposer d'un système racinaire. Pour celà, il faut faire tourner CRootBox de la façon suivante :

'''
    # RUN CROOTBOX
    system("inputs/crootbox.exe") 
      
    # Get the results of the simulation and save it in a .txt file
    rootsystem <- fread("outputs/current_rootsystem.txt", header = TRUE, colClasses = "numeric")
'''
Ensuite, nous devons également faire tourner MARSHAL afin d'obtenir les paramètres hydrauliques de ce système. Nous faisons ça de la façon suivante :

'''  
    # Default parameters set for the MARSHAL simulation 
    psiCollar <- -15000
    soil <- read_csv("inputs/soil.csv")
    conductivities <- read_csv("inputs/conductivities.csv")
        
    # RUN MARSHAL
    hydraulics <- getSUF(rootsystem, conductivities, soil, psiCollar)
'''

# Utilisation des fonctions
Une fois les variables rootsystem et hydraulics initialisées, nous pouvons utiliser les deux fonctions root_volume_calculation() and ZSUF_calculation().

## root_volume_calculation()
Cette fonction prend en argument la variable "rootsystem" et somme le volume de chaque segment racinaire réalisé lors de la simulation. 

Dans notre cas, nous considérons les segments de racines comme des cylindres dont le volume est calculé avec : $ \pi * r^2 * L$. L représente la longueur du segment et r le rayon.

La valeur retournée est un float unique représentant le volume en $cm^3$ de racines.

Il est bon de noter que des modifications pourraient être apportées à cette fonction, comme par exemple en considérant les racines comme des cylindres tronqués.

 
## ZSUF_calculation()
Cette fonction prend en argument la variable "hydraulics" et calcule pour chaque segment de racine la profondeur finale du segment multipliée par son SUF. Elle réalise ensuite la somme de tout les segments pour obtenir une unique valeur au niveau de la plante.

La valeur retournée est un float unique en cm donnant la profondeur moyenne à laquelle les racines captent très activement l'eau du sol.

 
