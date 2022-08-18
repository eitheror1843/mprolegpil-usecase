:- encoding(utf8).

:- op(1100, xfx, user:(<=)).
:- op(800, xfy, user:(#)).
:- dynamic (#)/2.
:- dynamic public_order/3.
:- dynamic conflict/3.
:- dynamic absolute_enforced_law/3.
:- dynamic fact/1.
:- set_prolog_flag(print_write_options, [portray(true), quoted(false), numbervars(true)]).

% Abbreviations
% AC: applying country

r :- reconsult(pil_interpreter_ai4legal).

t1 :- topp(usecase_ai4legal,claim(empl(o(ja)),co,inBreachOf(transfer(o(ja),o(c1),data(empl(o(ja)))),cj1))#ja).
t2 :- topp(usecase_ai4legal,claim(empl(o(ja)),co,inBreachOf(transfer(o(c1),o(c2),data(empl(o(ja)))),c12))#ja).

top(Jfile,Pfile,(P#Country)):-
   abolish((#)/2),
   abolish((fact/1)),
   consult(Jfile),
   solve(pln,0,hasJuris(P,Country)#Country),
   print('************** Jurisdiction OK. **************'),nl,
   consult(Pfile),
   solve(pil,0,(P#Country)).

% ?-topj(exj1_jm2,cp_rel(taro,yoko)#japan).
topj(Jfile,(P#Country)):-
   abolish((#)/2),
   abolish((fact/1)),
   consult(Jfile),
   solve(pln,0,hasJuris(P,Country)#Country),
   print('************** Jurisdiction OK. **************'),nl.
% ?-topp(ex1_jm3,cp_rel(taro,yoko)#japan).
topp(Pfile,(P#Country)):-
   abolish((#)/2),
   abolish((fact/1)),
   consult(Pfile),
   solve(pil,0,(P#Country)).

print_message(I,(P<=Q)#C,M):-!,
    print_rule(I,(P<=Q)#C),print(' '),
    print(M),nl.
print_message(I,no_counter_argument(_,_,Rel),_):-!,
    tab(I),print('No Exception:'), print(Rel),nl.
print_message(I,Q,M):-
    tab(I),print(Q),print(' '),print(M),nl.

print_rule(I,(P<=Q)#C):-!,
    tab(I),print('('),
    print(P),print('<='),nl,
    I2 is I + 2,
    print_body(I2,Q),
    print(')#'), print(C).

print_body(I,(B1,B)):-!,
    tab(I),print(B1),print(','),nl,
    print_body(I,B).
print_body(I,B1):-!,
    tab(I),print(B1).

% Phase = pil or pln (plain)

solve(Phase,I,(P,Q)#Country):-!,
    solve(Phase,I,P#Country), solve(Phase,I,Q#Country).
solve(_,_,call(P)#_):-
    !,
    call(P).
solve(_,I,P#Country):-
    I2 is I + 2,
    is_fact(P#Country),!,
    fact_check(I2,P#Country).
solve(_,I,P#Country):-
    I2 is I + 2,
    print_message(I2,'Starting to prove:',P#Country),fail.
solve(Phase,I,P#Country):-
%     choice_top(Phase,I,P#Country,AC),!,
% changed
    choice_top(Phase,I,P#Country,AC),
%     print_message(I,((P <= Q)#AC),'is now checked.'),
    (P <= Q)#AC,
    I2 is I + 2,
    print_message(I2,((P <= Q)#AC),'found.'),
    solve(Phase,I2,Q#AC),
    print_message(I2,(P#AC),'succeeded.'),
    print_message(I2,'Exception check:',(P#AC)),
    \+ counter_argument(Phase,I2,P#AC),
    print_message(I2,no_counter_argument(Phase,I2,P#AC),'succeeded.').
solve(_,I,P#Country):-
    I2 is I + 2,
    print_message(I2,'Failed to prove:',P#Country),!,fail.

fact_check(I2,P#Country):-
    fact(P#Country),print_message(I2,fact(P#Country),'found.').
fact_check(I2,P#Country):-
    \+ fact(P#Country),
    print_message(I2,fact(P#Country),'not found.'),!,fail.
fact_check(I2,P#Country):-
    print_message(I2,fact(P#Country),'found no more.'),!,fail.

% ground_check(hmc(Person,_)):-!,ground(Person).
% ground_check(_).

counter_argument(Phase,I,P#Country):-
    exception(P,R)#Country,
    print_message(I,'Try to deny:',R#Country),
    solve(Phase,I,R#Country),!,
    print_message(I,'Failed to deny',R#Country).

choice_top(pil,I,P#Country,ApplyingCountry):-!,
     var(ApplyingCountry),
     !,
%      print(starting(choice_top(pil,I,P#Country,ApplyingCountry))),nl,read(c),
     choice(I,P#Country,ApplyingCountry,[]).
choice_top(pln,_,_#Country,Country):-!, % For plain rersion, there is no "choice of law".
%      print(starting(choice_top(pln,I,P#Country,Country))),nl
     true.

choice(I,P#_,C,History):-
    member(C,History),!,
    I2 is I + 2,
    print_message(I2,applying_country_for(P),found(C)).
choice(_,envoi(_,_)#C,C,_):-!. % For every country, envoi rule is always each country's rule.
choice(I,P#C,AC,History):-
    var(AC),
    I2 is I + 2,
    solve(pil,I2,envoi(P,RC)#C),
    !,
    choice(I2,P#RC,AC,[RC|History]).
choice(I,P#C,C,_):- % If there are no specification of choice of law, the rule is a domestic rule.
    I2 is I + 2,
    print_message(I2,applying_country_for(P),'use default (applying country is self-country) and found'(C)),
    !.

groundize((P,Q)#Country):-!,
   groundize(P#Country), groundize(Q#Country).
groundize(P#Country):-
   is_fact(P#Country),!,
%    print(is_fact(P#Country)),nl,
   fact(P#Country).
%    print(found(fact(P)#Country)),nl.
groundize(P#Country):-
%    print(groundize(P#Country)),nl,
   (P <= Q)#Country,
%    print(found((P <= Q)#Country)),nl,
   groundize(Q#Country).

is_fact(P#_):-
   \+ (P<=_)#_.

