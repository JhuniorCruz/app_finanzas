import sys
from collections import defaultdict

def convert_val(val):
    if val == '\\N':
        return 'NULL'
    # Escape single quotes
    val = val.replace("'", "''")
    # Wrap in single quotes
    return f"'{val}'"

def clean_sql_dump(input_file, output_file):
    with open(input_file, 'r', encoding='utf8') as f_in:
        lines = f_in.readlines()
        
    schema_statements = []
    data_inserts = defaultdict(list)
    
    skip_current_block = True
    in_copy = False
    copy_table = ""
    copy_columns = ""
    
    for line in lines:
        if line.startswith('\\.'):
            if in_copy:
                in_copy = False
                continue
        
        if in_copy:
            if not skip_current_block:
                values = line.strip('\n').split('\t')
                formatted_vals = ', '.join(convert_val(v) for v in values)
                data_inserts[copy_table].append(f"INSERT INTO {copy_table} {copy_columns} VALUES ({formatted_vals});\n")
            continue

        if line.startswith('-- Name: '):
            if 'Schema: public' in line or 'Schema: -' in line and not 'Type: SCHEMA' in line and not 'Type: EXTENSION' in line:
                if 'Schema: public' in line:
                    skip_current_block = False
                else:
                    pass
            else:
                skip_current_block = True
        
        if line.startswith('COPY '):
            in_copy = True
            
            # Check if it is one of the tables we want to copy data from
            if (line.startswith('COPY public.debts ') or 
                line.startswith('COPY public.profiles ') or 
                line.startswith('COPY public.transactions ') or 
                line.startswith('COPY auth.users ') or 
                line.startswith('COPY auth.identities ')):
                
                skip_current_block = False
                parts = line.split(' FROM stdin;')
                if len(parts) > 0:
                    header = parts[0].replace('COPY ', '')
                    paren_idx = header.find('(')
                    if paren_idx != -1:
                        copy_table = header[:paren_idx].strip()
                        copy_columns = header[paren_idx:].strip()
            else:
                skip_current_block = True
            continue

        if line.startswith('SET ') or line.startswith('SELECT pg_catalog'):
            schema_statements.append(line)
            continue
            
        if line.startswith('\\'):
            continue
            
        if line.startswith('ALTER DEFAULT PRIVILEGES') or line.startswith('ALTER ') and ' OWNER TO ' in line:
            continue
            
        if not skip_current_block:
            schema_statements.append(line)
            
    with open(output_file, 'w', encoding='utf8') as f_out:
        f_out.write("DROP TABLE IF EXISTS public.debts, public.profiles, public.transactions CASCADE;\n")
        f_out.write("DROP FUNCTION IF EXISTS public.handle_new_user CASCADE;\n")
        for stmt in schema_statements:
            f_out.write(stmt)
            
        # Write inserts in topological order
        order = ['auth.users', 'auth.identities', 'public.profiles', 'public.debts', 'public.transactions']
        for table in order:
            if table in data_inserts:
                for insert in data_inserts[table]:
                    f_out.write(insert)

if __name__ == '__main__':
    clean_sql_dump('base_de_datos.txt', 'clean_backup_final.sql')
