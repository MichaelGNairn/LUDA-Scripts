#Functions for maps.
#WARNING: uses big query package, which is probably imported by the code at this point, but not done explicitly here.
def get_la_shapefile():
    try: 
        import geopandas
    except: 
        pip install geopandas
        import geopandas

    query = """SELECT LAD20CD, geom, BNG_E, BNG_N
    FROM `ons-luda-data-prod.ingest_geography.ltla_uk_2020_bqg_v1`
    """
    query_job = client.query(query, location="europe-west2",)
    
    la_geo = query_job.to_geodataframe
    return(la_geo())
