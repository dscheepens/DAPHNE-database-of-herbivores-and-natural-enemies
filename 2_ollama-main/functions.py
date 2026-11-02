from typing import List
import ast
import json
import pandas as pd
import numpy as np

def get_items(json):
    try: 
        if isinstance(json, dict) and json.get('items',False): 
            json = json['items']
        if isinstance(json, dict) and json.get('data',False): 
            json = json['data']
    except: 
        pass
    return(json)

def chunk_list(lst: List, n: int) -> List[List]:
    """Split list `lst` into chunks of size `n`."""
    return [lst[i:i + n] for i in range(0, len(lst), n)]

def flatten_cell(x):
    try:
        # Try to parse stringified lists like "['a', 'b']"
        val = ast.literal_eval(x) if isinstance(x, str) and x.startswith("[") and x.endswith("]") else x
    except (ValueError, SyntaxError):
        val = x
    # Join if list, otherwise just return as string
    if isinstance(val, list):
        return ", ".join(map(str, val))
    return str(val)


def string_to_json(json_string):
    """
    Handles cases with markdown code fences (```json ... ```).
    """
    
    # If it's a string, try to clean markdown fences and parse as JSON
    if isinstance(json_string, str):
        cleaned = json_string.strip()
        if cleaned.startswith("```json"):
            cleaned = cleaned[len("```json"):].strip()
        if cleaned.endswith("```"):
            cleaned = cleaned[: -len("```")].strip()
        try:
            json_string = json.loads(cleaned)
        except json.JSONDecodeError:
            print("Error in string_to_json. Returning None.")
            print(cleaned)
            # Leave it as-is if not valid JSON
            return None
        # if results are wrapped in `items` key: 
        json_string = get_items(json_string)
    return(json_string)

def get_herbivore_row(cols, sp): 
    df_row = pd.DataFrame([[""] * len(cols)],columns=cols) # empty dataframe
    df_row['Phylum'] = sp['taxonomy'].get('phylum', "")
    df_row['Class'] = sp['taxonomy'].get('class', "")
    df_row['Order'] = sp['taxonomy'].get('order', "")
    df_row['Family'] = sp['taxonomy'].get('family', "")
    df_row['Genus'] = sp['taxonomy'].get('genus', "")
    df_row['Species'] = sp['taxonomy'].get('species', "")
    df_row['Common Name'] = sp.get('common_name', "")
    df_row['Type'] = "herbivore" 
    df_row['Feeding Mode'] = sp.get('feeding_mode', "Herbivory")
    df_row['Host Plants'] = str([i.get('host_plant',"") for i in sp['host_plants']])
    df_row['Herbivore Is Pest'] = str([i.get('herbivore_is_pest_of_plant',False) for i in sp['host_plants']])
    df_row['Pest Importance'] = str([i.get('pest_importance',"NA") for i in sp['host_plants']])
    df_row['Herbivore Is BCA'] = str([i.get('biological_control_agent',False) for i in sp['host_plants']])
    df_row['Associated Industries'] = str(sp.get('associated_industries',[""]))
    df_row['Invasive'] =  str(sp.get('herbivore_invasive_in',[""]))
    df_row['Vectors'] = str(sp.get('pathogen_vector', [""]))
    df_row['Synonyms'] = str(sp.get('synonyms',[""]))
    return df_row
                
def get_enemy_row(cols, sp):  
    df_row = pd.DataFrame([[""] * len(cols)],columns=cols) # empty dataframe
    df_row['Phylum'] = sp['taxonomy'].get('phylum', "")
    df_row['Class'] = sp['taxonomy'].get('class', "")
    df_row['Order'] = sp['taxonomy'].get('order', "")
    df_row['Family'] = sp['taxonomy'].get('family', "")
    df_row['Genus'] = sp['taxonomy'].get('genus', "")
    df_row['Species'] = sp['taxonomy'].get('species', "")
    df_row['Common Name'] = sp.get('common_name', "")
    df_row['Type'] = "natural enemy" 
    df_row['Feeding Mode'] = sp.get('feeding_mode', "NA")
    df_row['Herbivore Prey'] = str([i.get('herbivorous_prey',"") for i in sp['prey_species']])
    df_row['Important Natural Enemy'] =  str([i.get('important_natural_enemy',False) for i in sp['prey_species']])
    df_row['Biological Control'] =  str([i.get('biological_control',False) for i in sp['prey_species']])
    df_row['Associated Industries'] = str(sp.get('associated_industries',[""]))
    df_row['Associated Plants'] = str(sp.get('associated_plants',[""]))
    df_row['Hyperparasitoids'] =  str(sp.get('hyperparasitoids',[""]))
    df_row['Invasive'] =  str(sp.get('invasive_in',[""]))
    df_row['Vectors'] = str(sp.get('vectors', [""]))
    df_row['Synonyms'] = str(sp.get('synonyms',[""]))
    return df_row


def llm_generate(ollama, MODEL, SEED, chat_history, prompt_format=None):
    resp = ""
    for chunk in ollama.chat(
        model=MODEL,
        messages=chat_history,
        options={"seed": SEED, 
                 "think": True,
                 "num_predict": -1,
                 #"temperature": 0
                },
        stream=True,
        #format=prompt_format
    ):
        if "message" in chunk and "content" in chunk["message"]:
            resp += chunk["message"]["content"]
    return resp


def get_species_list(ollama, MODEL, SEED, abstract, system_prompt_text, system_prompt_json, user_prompt, prompt_format):

    prompt = f"""
    Here are a title, abstract and keywords: {abstract}. 
    {user_prompt}
    Explain your reasoning.
    """

    chat_history = [
        {"role": "system", "content": system_prompt_text},
        {"role": "user", "content": prompt} 
    ]

    try:
        resp_text = llm_generate(ollama, MODEL, SEED, chat_history)
    except Exception as e:
        print(f"Text generation error: {e}")
        resp_text = None

    if resp_text is not None: 
        
        prompt = f"""
        Here are a title, abstract and keywords: {abstract}. 
        {user_prompt}
        """
    
        chat_history = [
            {"role": "system", "content": system_prompt_json},
            {"role": "user", "content": prompt} 
        ] 
    
        chat_history = chat_history + [{"role": "assistant", "content": resp_text},
                                       {"role": "user", "content": f"Follow this JSON schema exactly and output JSON only: {prompt_format}"}]
    else: 
        prompt = f"""
        Here are a title, abstract and keywords: {abstract}. 
        {user_prompt}
        Follow this JSON schema exactly and output JSON only: {prompt_format}
        """
        
        chat_history = [
        {"role": "system", "content": system_prompt_json},
        {"role": "user", "content": prompt} 
        ] 
    
    try:
        resp = llm_generate(ollama, MODEL, SEED, chat_history, prompt_format)
        species_list = string_to_json(resp)
        # if single-item list, unwrap: 
        if isinstance(species_list, list) and len(species_list) == 1 and isinstance(species_list[0], dict):
            species_list = species_list[0]
        # if wrapped in `items`: 
        species_list = get_items(species_list)
    except Exception as e:
        print(f"Error: {e}")
        species_list = None
        
    return (species_list, resp_text)



def batch_species(species_list, batch_size=5):
    """Split a list of species into batches of given size."""
    return [species_list[i:i + batch_size] for i in range(0, len(species_list), batch_size)]



def get_model_responses(ollama, MODEL, SEED, system_prompt_text, system_prompt_json, species_list, abstract, user_prompt_herbivores, user_prompt_enemies, prompt_format_herbivore, prompt_format_enemy, cols):
    
    df = pd.DataFrame(columns=cols) # empty dataframe
    
    if species_list is not None: 
        if species_list.get("herbivores",[]) != []: 
            flag=False
            
            # generate one text response for all herbivores
            prompt_initial=f"""
                         Here are a title, abstract and keywords: {abstract}.\n
                         Provide information for the following herbivores: {', '.join(species_list["herbivores"])}.
                         {user_prompt_herbivores}\n
                         Explain your reasoning.
                         """
            
            chat_history = [
                {"role": "system", "content": system_prompt_text},
                {"role": "user", "content": prompt_initial} 
            ]
            
            resp_herbivores = llm_generate(ollama, MODEL, SEED, chat_history)
            
            for i, sp_list in enumerate(batch_species(species_list["herbivores"])): # batches of 5
                # generate JSON 
                user_prompt=f"""
                             Return the following herbivores: {', '.join(sp_list)}
                             Provide the information following this JSON schema exactly and output JSON only: {prompt_format_herbivore}
                             """

                chat_history = [
                {"role": "system", "content": system_prompt_json},
                {"role": "user", "content": prompt_initial} 
                ] + [
                {"role": "assistant", "content": resp_herbivores},
                {"role": "user", "content": user_prompt} 
                ]
                
                resp = llm_generate(ollama, MODEL, SEED, chat_history)
                sp_json = string_to_json(resp)
                
                if sp_json is not None:
                    #sp_json = if_items(sp_json)
                    for sp in sp_json:
                        #sp = correct_list(sp)
                        try: 
                            df_row = get_herbivore_row(cols, sp) 
                            df_row['Generated Response'] = resp_herbivores
                            df = pd.concat([df, df_row], ignore_index=True)
                        except Exception as e:
                            print(f"Error in herbivores: {e}.")
                            print('sp:')
                            print(sp)
                            print('sp_json:')
                            print(sp_json)
                            flag = True
                            break
                if flag:   
                    print("trying again...") 
                    user_prompt=f"""
                     Return the following herbivores: {', '.join(sp_list)}
                     Provide the information following this JSON schema exactly and output JSON only: {prompt_format_herbivore}
                     """
    
                    chat_history = [
                    {"role": "system", "content": system_prompt_json},
                    {"role": "user", "content": prompt_initial} 
                    ] + [
                    {"role": "assistant", "content": resp_herbivores},
                    {"role": "user", "content": user_prompt} 
                    ]
                    
                    resp = llm_generate(ollama, MODEL, SEED, chat_history)
                    sp_json = string_to_json(resp)
    
                    if sp_json is not None:
                        #sp_json = if_items(sp_json)
                        for sp in sp_json:
                            #sp = correct_list(sp)
                            try: 
                                df_row = get_herbivore_row(cols, sp) 
                                df_row['Generated Response'] = resp_herbivores
                                df = pd.concat([df, df_row], ignore_index=True)
                            except Exception as e:
                                print(f"Error in herbivores: {e}.")
                                print('sp:')
                                print(sp)
                                print('sp_json:')
                                print(sp_json)
                
        if species_list.get("natural_enemies",[]) != []:
            flag=False

            # generate one text response for all natural enemies
            prompt_initial=f"""
                         Here are a title, abstract and keywords: {abstract}.\n
                         Provide information for the following natural enemies: {', '.join(species_list["natural_enemies"])}.
                         {user_prompt_enemies}\n
                         Explain your reasoning.
                         """
            
            chat_history = [
                {"role": "system", "content": system_prompt_text},
                {"role": "user", "content": prompt_initial} 
            ]
            
            resp_enemies = llm_generate(ollama, MODEL, SEED, chat_history)
            
            for i, sp_list in enumerate(batch_species(species_list["natural_enemies"])): # batches of 5
                user_prompt=f"""
                             Return the following natural enemies: {', '.join(sp_list)}
                             Provide the information following this JSON schema exactly and output JSON only: {prompt_format_enemy}
                             """

                chat_history = [
                {"role": "system", "content": system_prompt_json},
                {"role": "user", "content": prompt_initial} 
                ] + [
                {"role": "assistant", "content": resp_enemies},
                {"role": "user", "content": user_prompt} 
                ]
                
                resp = llm_generate(ollama, MODEL, SEED, chat_history)
                sp_json = string_to_json(resp)
                
                if sp_json is not None: 
                    #sp_json = if_items(sp_json)
                    for sp in sp_json:
                        #sp = correct_list(sp)
                        try: 
                            df_row = get_enemy_row(cols, sp)
                            df_row['Generated Response'] = resp_enemies
                            df = pd.concat([df, df_row], ignore_index=True)
                        except Exception as e:
                            print(f"Error in enemies: {e}.")
                            print('sp:')
                            print(sp)
                            print('sp_json:')
                            print(sp_json)
                            flag=True
                            break
                if flag:
                    print("trying again...") 
                    user_prompt=f"""
                     Return the following natural enemies: {', '.join(sp_list)}
                     Provide the information following this JSON schema exactly and output JSON only: {prompt_format_enemy}
                     """
    
                    chat_history = [
                    {"role": "system", "content": system_prompt_json},
                    {"role": "user", "content": prompt_initial} 
                    ] + [
                    {"role": "assistant", "content": resp_enemies},
                    {"role": "user", "content": user_prompt} 
                    ]
                    
                    resp = llm_generate(ollama, MODEL, SEED, chat_history)
                    sp_json = string_to_json(resp)
    
                    if sp_json is not None: 
                        #sp_json = if_items(sp_json)
                        for sp in sp_json:
                            #sp = correct_list(sp)
                            try: 
                                df_row = get_enemy_row(cols, sp)
                                df_row['Generated Response'] = resp_enemies
                                df = pd.concat([df, df_row], ignore_index=True)
                            except Exception as e:
                                print(f"Error in enemies: {e}.")
                                print('sp:')
                                print(sp)
                                print('sp_json:')
                                print(sp_json)
                                

    return df




