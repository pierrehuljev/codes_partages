# update conductivities.py 

### Script python permettant d'automatiser le changement de conductivités dans le fichier MARSHAL/inputs/conductivities.csv afin de faciliter le passage de MECHA à MARSHAL

#### Auteur : Mattias Van Eetvelt

## Doc
La fonction prend 4 arguments : 

- `df` : dataframe contenant les conductivités. Doit être chargé préalablement sous forme d'un pandas DataFrame.

- `values` : liste de 2 éléments contenant les différentes valeurs de Kr obtenue via MECHA. L'ordre de ces valeurs est important! La première valeur correspond au Kr de maturité #0 et la seconde valeur au Kr de maturité #1. Si `on = allroots` alors `values` est une liste de 4 valeurs dans l'ordre suivant :  [Kr mat.#0 tap root, Kr mat.#1 tap root, Kr mat.#0 lat. root, Kr mat.#1 alt root] où mat.#0 et mat.#1 sont les différents niveau de maturité de MECHA.

- `on` : string permettant de préciser quelles conductivités doivent être modifiées. Trois cas possibles : taproots, lateralroots ou allroots.

- `output_fname` : Nom du fichier .csv produit. Facultatif.  

## Exemple

```ruby
import pandas as pd

df_conduc = pd.read_csv(<path>) 
kr_MECHA = [0.00011, 3.8e-5] #attention à l'ordre!!

update_conductivities(df=df_conduc, values=kr_MECHA, on='taproots', output_fname='exemple_filename')
```
Un exemple plus complet se trouve dans le Jupyter Notebook de ce repo.