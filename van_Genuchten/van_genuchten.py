#%%
import os ; wd=os.getcwd() ; os.chdir(wd)
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pynverse import inversefunc

# define useful functions
def vanGenuchten(psi, unit='cm'):
    ''' Computes the water retention, theta, for a given value of psi using the van Genuchten model.
        The type of soil considered is a loam soil.
    
    Args:
        psi:   The soil suction/soil water potential (psi_m) expressed in [cm] or in [hPa]. Default is [cm].
        unit:  Specifies the unit of the value of psi. If unit is hPa then it is first converted into cm.
        
    Returns:
        Theta, the water retention corresponding to the given psi and is expressed in [cm^3/cm^3].
    '''
    # function parameters for loam soil (from HYDRUS)
    theta_s = 0.3991   # [cm^3/cm^3]
    theta_r = 0.0609   # [cm^3/cm^3]
    alpha = 0.0111     # [cm^-1]
    n = 1.4737         # [-]
    m = 1-1/n          # [-]
    # convert units of psi : hPa -> cm 
    if unit=='hPa':
        psi = 10*psi/9.81
    if unit != 'hPa' and unit != 'cm':
        print(('\033[31;1;4mvanGenucthen():Wrong unit provided; the only untis accepted are `cm` or `hPa`\033[0m')) # print error in red and underlined text
    # compute water retention using the van Genuchten model
    water_retention = theta_r + (theta_s - theta_r)/(((1 + (alpha*abs(psi))**n))**m)
    return water_retention

def analytical_inv_vanGenuchten(theta, unit='cm'):
    ''' Computes the soil suction/soil water potential for a given water content, theta, expressed in [cm^3/cm^3].
        The computation is done using the analitycal solution of the inverse of the van Genuchten model.
        The type of soil considered is a loam soil.
    
    Args:
        theta:  Water content in cm^3/cm^3.
        unit:   Specifies the unit of the value returned. Defaulf is cm.
    
    Returns:
        Psi, the soil water potential in [cm of water].
    '''
    # function parameters for loam soil (from HYDRUS)
    theta_s = 0.3991   # [cm^3/cm^3]
    theta_r = 0.0609   # [cm^3/cm^3]
    alpha = 0.0111     # [cm^-1]
    n = 1.4737         # [-]
    m = 1-1/n          # [-]
    # compute psi using inverse van Genuchten
    psi = 1/alpha * (((theta-theta_r)/(theta_s-theta_r))**(-1/m) - 1)**(1/n) 
    # convert unit if necessary
    if unit == 'hPa':
        return psi*9.81/10
    else:
        return psi
    
def compute_avg(psi0, unit='hPa'):
    '''Computes the average values of theta [cm^3/cm^3] for a given profile of soil.
    
    Args:
        psi0:  Vector of values of theta for each layer of depth. Psi values are recommended to be in hPa.
               Corresponds the colum 'psi' from the soil.csv file.
    
    Returns:
        List of average values of theta in cm^3/cm^3. If len(psi0)==n then the list returned has a size of n-1.
    '''
    theta_avg = []
    for i in range(len(psi0)-1):
        theta_profile = (vanGenuchten(psi0[i+1], unit=str(unit)) + vanGenuchten(psi0[i], unit=str(unit)))/2
        theta_avg.append(theta_profile)
    return theta_avg

def compute_water_stock(thetas_average, depth=40, verbatim=False):
    """ Computes the total water stock in the soil in cm^3.

    Args:
        thetas_avg:  Average values of theta [cm^3/cm^3]. 
        depth:       Soil profile depth. Defaults to 40 [cm].
        verbatim:    If True, prints the result on the console. Defaults to False.

    Returns:
        Total soil water stock in cm^3, which are the same units as the output of MARSHAL.
    """
    np.array(thetas_average)
    water_content = sum(thetas_average*depth) #cm
    water_content_cm3 = water_content/100*1e6 #cm^3
    if verbatim:
        print("Total water content in the soil is = " + str(round(water_content,4))+" cm or "
              + str(round(water_content_cm3, 4)) + " cm3")
    else:
        return water_content_cm3

def compute_new_psi(S0, T, unit='hPa', func='numerical', export=False, verbatim=False):
    ''' Computes new values of psi, based on an initial water stock and a given value of transpiration 
    
    Args:
        S0:        Initial water stock [cm^3].
        T:         Transpiration output from MARSHAL [cm^3].
        unit:      Unit to use from vanGenuchten function. Default is hPa.
        func:      Function to use for computing the inverse of van Genuchten. Default is numerical.
        export:    To export results in a csv file. Default is False.
        verbatim : To print the results. Default is False.
    
    Returns:
        List of the 4 new values of psi. 
    '''
    psi0 = -15000 ; theta0 = vanGenuchten(psi0, unit=str(unit))  # theta_0 is constant 
    # compute new water stock and convert it from cm3 to cm
    Si = S0-T    # [cm^3]
    Si *= 1e-4   # [cm]
    # solve equation for theta -> see README
    theta1 = (Si-20*theta0)/100 
    # and compute new value of psi
    if func=='analytical':
        psi1 = analytical_inv_vanGenuchten(theta1)
    else:
        psi1 = inv_vanGenuchten(theta1)
    # save as list
    all_psi = [psi0, float(-psi1), float(-psi1), float(-psi1)]
    # other params
    if export:
        export_psi(all_psi)
    if verbatim:
        print('New values of psi are : ' + str(all_psi) + '[hPa]')
    return all_psi

def export_psi(new_psis, filename="new_soil"):
    '''Exports results in a csv file
    Args:
        new_psis:  List of new values of psi
        filename:  Name of the file exported
    
    Returns:
        DataFrame containing the new values of psi
    '''
    z = [0, -40, -80, -120]
    df = pd.DataFrame({'z':z, 'psi':new_psis})
    df.to_csv('./new_csv/'+ filename +'.csv')
    return df
    
#%% 
# sanity check : plot numerical sol vs analitical sol
## declare buffers & dummy points for graphs
psi = [1, 10, 30, 100, 1000, 1500, 10000, 15000, 100000]
thetas = []
inv_thetas = []
inv_analytical = [] 

# compute theta's - direct function
for i in psi:
    thetas.append(vanGenuchten(i, unit='cm'))

# compute inverse function - numerically
inv_vanGenuchten = inversefunc(vanGenuchten)
for i in thetas:
    inv_thetas.append(inv_vanGenuchten(i))

# compute inverse function - analytically
for i in thetas:
    inv_analytical.append(analytical_inv_vanGenuchten(i))

# make subplots with all 3 graphs
fig, axs = plt.subplots(1, 2, figsize=(10,5))
axs[0].plot(psi, thetas, 'b-')
axs[0].set_xscale('log')
axs[0].set_title('van Genuchten')
axs[0].grid(linestyle=':')
axs[0].set_xlabel('Valeur absolue log $\psi_m \quad [cm]$')
axs[0].set_ylabel(r"Rétention d'eau $\theta \quad [cm^3/cm^3]$")

axs[1].plot(thetas, inv_thetas, 'b-', label='numerique')
axs[1].plot(thetas, inv_analytical, 'r--', label='analytique')
axs[1].set_title('inverse van Genuchten')
axs[1].set_yscale('log')
axs[1].grid(linestyle=':')
axs[1].set_ylabel('Valeur absolue log $\psi_{m} \quad [cm]$')
axs[1].set_xlabel(r"Rétention d'eau $\theta \quad [cm^3/cm^3]$")
axs[1].legend(loc='best')

plt.savefig('./img/vanGenuchten_subplots.png', dpi=500)
plt.tight_layout()
plt.show()
#%%
# compute initial soil water content based on default values
# in MARSHAL's soil.csv file
soil= pd.read_csv('./soil.csv')
psi0 = soil['psi']
print(psi0)
avg = compute_avg(psi0)
print(avg)
stock = compute_water_stock(avg, verbatim=True)