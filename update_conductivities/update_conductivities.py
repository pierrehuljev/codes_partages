import pandas as pd

def update_conductivities(df, values:list, on="taproots", output_fname=None):
    ''' df = dataframe contenant les conductivités. Doit être chargé préalablement.
        values = liste de 2 éléments contenant les différentes valeurs de Kr obtenue via MECHA. L'ordre de ces valeurs est important!
                 La première valeur correspond au Kr de maturité #0 et la seconde valeur au Kr de maturité #1. Si on == allroots
                 alors values est une liste de 4 valeurs dans l'ordre suivant : 
                 [Kr mat.#0 tap root, Kr mat.#1 tap root, Kr mat.#0 lat. root, Kr mat.#1 alt root]
        on = string permettant de préciser quelles conductivités doivent être modifiées. Trois cas possibles : taproots, lateralroots
             ou allroots.
        output_fname = Nom du fichier .csv produit. Facultatif.       
    '''
    
    df_copy = df.copy(deep=True)
    taproots = ['Taproot', 'Basalroot', 'Shootborneroot']
    lateralroots = ['Lateral', 'LongLateral']
    
    if on == "taproots":
        subset = df_copy.loc[(df_copy['order'].isin(taproots)) & (df_copy['type'] == 'kr')]
        subset.loc[(subset['x'] == 0.0) | (subset['x'] == 9.0), 'y'] = values[0]    #set value to Kr matutity level #0
        subset.loc[(subset['x'] == 20.0) | (subset['x'] == 50.0), 'y'] = values[1]  #set value to Kr matutity level #1
        #replace old values by the new ones
        idx = subset.index
        df_copy.loc[idx, 'y'] = subset['y']
        
    elif on == "lateralroots":
        subset = df_copy.loc[(df_copy['order'].isin(lateralroots)) & (df_copy['type'] == 'kr')]
        subset.loc[(subset['x'] == 0.0) | (subset['x'] == 13.0), 'y'] = values[0]   #set value to Kr matutity level #0
        subset.loc[(subset['x'] == 13.1) | (subset['x'] == 50.0), 'y'] = values[1]  #set value to Kr matutity level #1
        #replace old values by the new ones
        idx = subset.index
        df_copy.loc[idx, 'y'] = subset['y']
        
    elif on == "allroots":
        subset_tap = df_copy.loc[(df_copy['order'].isin(taproots)) & (df_copy['type'] == 'kr')]
        subset_tap.loc[(subset_tap['x'] == 0.0) | (subset_tap['x'] == 9.0), 'y'] = values[0]    #set value to Kr matutity level #0
        subset_tap.loc[(subset_tap['x'] == 20.0) | (subset_tap['x'] == 50.0), 'y'] = values[1]  #set value to Kr matutity level #1
        subset_lat = df_copy.loc[(df_copy['order'].isin(lateralroots)) & (df_copy['type'] == 'kr')]
        subset_lat.loc[(subset_lat['x'] == 0.0) | (subset_lat['x'] == 13.0), 'y'] = values[2]   #set value to Kr matutity level #0
        subset_lat.loc[(subset_lat['x'] == 13.1) | (subset_lat['x'] == 50.0), 'y'] = values[3]  #set value to Kr matutity level #1
        #replace old values by the new ones
        idx_tap = subset_tap.index
        idx_lat = subset_lat.index
        df_copy.loc[idx_tap, 'y'] = subset_tap['y']
        df_copy.loc[idx_lat, 'y'] = subset_lat['y']
        

    #write new csv file
    if output_fname != None:
        df_copy.to_csv(str(output_fname)+'.csv', sep=',', index=False)
    else:
        df_copy.to_csv(str(modified_conductivities)+'.csv', sep=',', index=False)

    
