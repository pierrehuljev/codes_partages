# Link_Marshal_APSIM_Transpiration.R - Lien entre APSIM et MARSHAL

### Ce script permet d'associer la transpiration de MARSHAL avec celle de APSIM

### Auteur: Pierre Huljev

## 1. Principe


Marshal prend 'soil_psi_boucle' en entrée dans son modèle. Grâce à ces valeurs de psi il nous permet de calculer une transpiration maximale en $cm^3/plante*jour$. Cependant, la valeur de transpiration dans APSIM est en $mm/jour$. Il faut donc faire une transformation en multipliant la transpiration de MARSHAL par 0.008 (car on considère que pour du maïs, il y a 8 plantes par $m^2$).

Une fois que les unités sont les mêmes on peut comparer la transpiration calculée dans MARSHAL et dans APSIM. En sachant que celle dans MARSHAL est une valeur maximale par jour, si cette dernière est plus petite que la valeur dans APSIM, il faut prendre la transpiration de MARSHAL. 

Une fois cela fait il faut update les psi dans le dataframe pour MARSHAL. Pour ce faire on peut utiliser la fonction inverse de Van Genuchten. Les 4 paramètres utilisés pour un sol limoneux sont: 
- $\theta_s = 0.3991 [cm^3/cm^3]$ 
- $\theta_r = 0.0609 [cm^3/cm^3]$ 
- $\alpha = 0.0111   [cm^{-1}]$ 
- $n = 1.4737        [-]$ 

Et donc pour calculer le potentiel hydrique ($\psi$) à partir des paramètres du modèle de Van Genuchten et de $\theta$ la proportion d'eau dans la couche, on écrit:

$$
\psi = \left( \left( \left( \frac{\theta_s - \theta_r}{\theta - \theta_r} \right)^{\frac{1}{m}} - 1 \right)^{\frac{1}{n}} \right) \cdot \left( - \frac{1}{\alpha} \right)
$$

## 2. Le script

"Link_Marshal_APSIM_Transpiration.R" vous permet donc de lier APSIM et MARSHAL. Libre à vous maintenant de faire varier les paramètres du sol ou les paramètres architecturaux afin de voir les différentes évolutions au niveau de la biomasse/du rendement. 


