
--#SET TERMINATOR @

create or replace trigger PayOut
after update on Quest
referencing
    old as A
    new as Z
for each row mode db2sql
when (
    A.succeeded is null 
	AND Z.succeeded is not null
)
begin atomic
    update (select T.loot#, T.realm, T.day, T.theme, T.login,
               (select  count(*)
                from Actor Ac
                where Ac.realm = T.realm
                  and Ac.day   = T.day
                  and Ac.theme = T.theme
               ) as #players
        from Loot T
       ) as L
	set L.login = ( select login
                from Actor Ac
                where Ac.realm = L.realm
                  and Ac.day   = L.day
                  and Ac.theme = L.theme
                order by rand() * L.#players
                limit 1
               )
	where L.realm = Z.realm
		and L.day   = Z.day
		and L.theme = Z.theme
		and L.login is null -- sanity checks
		and L.#players > 0;

end@
