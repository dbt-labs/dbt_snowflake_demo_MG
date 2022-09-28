{{
    config(
        materialized = 'table'
    )
}}

select cast(1 as decimal(28,0)) as one