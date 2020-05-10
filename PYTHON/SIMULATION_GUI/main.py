import dash
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input,Output,State
import dash_table
import numpy
import pandas
from numpy.random import randint,rand
import requests
from bs4 import BeautifulSoup
import simulationMethods


app=dash.Dash()

app.title="SYMULATOR"

app.layout=html.Div([
                      html.Div(id="id_form",
                               children=[
                                          html.P([
                                            html.Div(id="id_contaier_label_scenarios",children=[html.Label("LICZBA SCENARIUSZY")]), 
                                            dcc.Input(id="id_scenarios",type="number",value=1000)
                                           ]),
                                          html.P([
                                            html.Div(id="id_container_label_league",children=[html.Label(id="id_label_league",children="LIGA")]),
                                            dcc.Dropdown(id="id_league",multi=False,value=0,
                                                        options=[{"label":"EKSTRAKLASA","value":0},{"label":"FORTUNA I LIGA","value":1},{"label":"II LIGA","value":2},{"label":"III LIGA GR.3","value":3}])
                                           ]),
                                          html.P([
                                            html.Div(id="id_container_label_stage",children=[html.Label(id="id_label_stage",children="FAZA SEZONU")]),
                                            dcc.Dropdown(id="id_stage",multi=False,value=0,
                                                        options=[{"label":"ZASADNICZA","value":0},{"label":"PO PODZIALE","value":1}])
                                           ]),    
                                          html.P([
                                            html.Div(id="id_container_label_promoted",children=[html.Label("AWANS")]), 
                                            dcc.Input(id="id_promoted",type="number",value=2,disabled=True)
                                           ]),
                                          html.P([
                                            html.Div(id="id_container_label_cups",children=[html.Label("EUROPEJSKIE PUCHARY")]), 
                                            dcc.Input(id="id_cups",type="number",value=3)
                                           ]),                                           
                                          html.P([
                                            html.Div(id="id_container_label_playoff",children=[html.Label("BARAŻE")]), 
                                            dcc.Input(id="id_playoff",type="number",value=6,disabled=True)
                                           ]), 
                                          html.P([
                                            html.Div(id="id_container_label_degraded",children=[html.Label("SPADEK")]), 
                                            dcc.Input(id="id_degraded",type="number",value=3)
                                           ]),  
                                          html.P([
                                            html.Div(id="id_container_label_method",children=[html.Label(id="id_label_method",children="METODA SYMULACJI")]),
                                            dcc.Dropdown(id="id_method",multi=False,value=0,
                                                        options=[{"label":"MODEL BAYESOWSKI","value":0},{"label":"ROZKŁAD JEDNOSTAJNY","value":1}])
                                           ]), 
                                           html.Button(id="id_submit",type="button",n_clicks=0,children="URUCHOM SYMULACJĘ")
                                        ]
                               ),
                      html.Div(id="id_result_section",
                               children=[
                                         html.Div(id="id_table_container",children=[])
                                         
                                         ]
                                         
                                )
                      
                    ])



############# DISABLE / ENABLE INPUT W ZALEŻNOŚCI OD LIGI #################

@app.callback(Output(component_id="id_promoted",component_property="disabled"),
               [Input(component_id="id_league",component_property="value")]
               )
def manage_promoted(in_league):
    if in_league==0:
        return True
    elif in_league==1 or in_league==2 or in_league==3:
        return False      


@app.callback(Output(component_id="id_stage",component_property="disabled"),
               [Input(component_id="id_league",component_property="value")]
               )
def manage_stage(in_league):
    if in_league==0:
        return False
    elif in_league==1 or in_league==2 or in_league==3:
        return True 

@app.callback(Output(component_id="id_cups",component_property="disabled"),
               [Input(component_id="id_league",component_property="value")]
               )     
def manage_cups(in_league):
    if in_league==0:
        return False
    elif in_league==1 or in_league==2 or in_league==3:
        return True 

@app.callback(Output(component_id="id_playoff",component_property="disabled"),
               [Input(component_id="id_league",component_property="value")]
               )     
def manage_playoff(in_league):
    if in_league==0 or in_league==3:
        return True
    elif in_league==1 or in_league==2:
        return False 

#############################################################################


############# RUN SIMULATION ########################################
@app.callback(Output(component_id="id_table_container",component_property="children"),
               [Input(component_id="id_submit",component_property="n_clicks")],
               [State(component_id="id_scenarios",component_property="value"),
                     State(component_id="id_league",component_property="value"),
                     State(component_id="id_promoted",component_property="value"),
                     State(component_id="id_cups",component_property="value"),
                     State(component_id="id_stage",component_property="value"),
                     State(component_id="id_degraded",component_property="value"),
                     State(component_id="id_playoff",component_property="value"),
                     State(component_id="id_method",component_property="value")
               ]
               )
def simul(n_clicks,in_scenarios,in_league,in_promoted,in_cups,in_stage,in_degraded,in_playoffs,in_simulation_method):
    if n_clicks>0:
        out_df=simulationMethods.run_simulation(in_scenarios,in_league,in_stage,in_promoted,in_cups,in_playoffs,in_degraded,in_simulation_method)
        #out_df=run_simulation(in_scenarios,in_league,in_stage,in_promoted,in_cups,in_playoffs,in_degraded,in_simulation_method)
        
        table_comp = dash_table.DataTable(id="out_table",columns=[{"name":i,"id":i} for i in out_df.columns],data=out_df.to_dict("records"),style_table={"width":"20%","height":"20%"})
        return table_comp



if __name__=="__main__":
    app.run_server()