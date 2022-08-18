% negation/1 functions as negation-as-failure
(negation(_) <=
  call(true))#_.
exception(negation(P),P)#_.
(envoi(negation(P),RC) <=
  envoi(P,RC))#_.

% ja: Japan
% c1: Country 1 inside EU
% c2: Country 2 outside EU
% co: Japanese company
% cj1: contract (cj1)
% c12: contract (c12)
% o/1: office
% subj/2: subject of data
% empl/1: employee
% data/1: personal data
% prjd/2: prejudice
% jurisDiff/2: different as juridical personality
% operator/3: business operator
% ctrlr/3: controller
% ctrlPrcsr/3: controller or processor
% recipient/3: recipient
% asg/2: appropriate safeguard in GDPR
% sa/2: supervisory authority
% inst/2: instrument
% pb/2: public body or authority
% sdpc: standard data protection clause
% adminArrange/3: administrative arrangement

% Act on General Rules for Application of Laws, AGRAL (Japan's PIL)
(envoi(claim(Pla,Def,inBreachOf(_,Contract)),RC) <=
  formulationAndEffect(Pla,Def,Contract,RC))#ja.

% the prerequisites of Article 7,8(1),9, AGRAL
(formulationAndEffect(Pla,Def,Contract,RC) <=
  plaintiff(Pla),
  defendant(Def),
  jurisAct(Contract,Pla,Def),
  agral(_,[Contract,RC]))#ja.

% Article 7, AGRAL
(agral(7,[Contract,RC]) <=
  choseAtThatTime(parties(Contract),RC))#ja.

% Article 8(1), AGRAL
(agral(8,[Contract,RC]) <=
  agral(8,_,[Contract,RC]))#ja.
(agral(8,1,[Contract,RC]) <=
  negation(choseAtThatTime(parties(Contract),RC)),
  closelyConnectedPlace(Contract,RC))#ja.

% Article 9, AGRAL
(agral(9,[Contract,RC]) <=
  changedLater(parties(Contract),RC))#ja.
(exception(agral(7,[Contract,_]),changedLater(parties(Contract),_)))#ja.
(exception(agral(8,1,[Contract,_]),changedLater(parties(Contract),_)))#ja.

(exception(agral(9,[Contract,RC]),ex_agral(9,[Contract,RC])))#ja.
(ex_agral(9,[Contract,RC]) <=
  prjd(changedLater(parties(Contract),RC),right(Y)),
  thirdParty(Y,parties(Contract),agral))#ja.

% we assume that claims for damages are accepted iff their relevant data transfer is illegal
(claim(_,_,inBreachOf(P,_)) <=
  illegal(P))#_.

% we currently omit Article 23, APPI

% Act on the Protection of Personal Information, APPI (Japan's law on data protection)
% Article 24, APPI
(illegal(transfer(S,G,Data)) <=
  appi(_,transfer(S,G,Data)))#ja.

(appi(24,transfer(S,G,Data)) <=
  operator(X,transfer(S,G,Data),appi),
  recipient(Y,transfer(S,G,Data),appi),
  inThirdCountry(Y,ja),
  thirdParty(Y,X,appi),
  transfer(S,G,Data))#ja.
exception(appi(24,transfer(S,G,Data)),ex_appi(24,transfer(S,G,Data)))#ja.
(ex_appi(24,transfer(S,G,Data)) <=
  subj(Subj,Data),
  consent(Subj,transfer(S,G,Data)))#ja.
(ex_appi(24,transfer(S,G,Data)) <=
  ex_appi(23,1,transfer(S,G,Data)))#ja.

% p. 45 and p. 5 of the two guidelines of APPI
(thirdParty(Y,X,appi) <=
  jurisDiff(Y,X))#ja.

% General Data Protection Regulation, GDPR
% Article 44, GDPR: https://gdpr-text.com/read/article-44/#para_gdpr-a-44
(illegal(transfer(S,G,Data)) <=
  gdpr(_,transfer(S,G,Data)))#c1.

(gdpr(44,transfer(S,G,Data)) <=
  inThirdCountry(G,eu),
  transfer(S,G,Data))#c1.
exception(gdpr(44,transfer(S,G,Data)),ex_gdpr(44,transfer(S,G,Data)))#c1.

% Article 45(1), GDPR: https://gdpr-text.com/read/article-45/#para_gdpr-a-45_1
(ex_gdpr(44,transfer(S,G,Data)) <=
  gdpr(45,_,transfer(S,G,Data)))#c1.
(gdpr(45,1,transfer(_,G,_)) <=
  countryOf(C,G),
  adequateDecision(eu,C))#c1.

% Article 45(2), GDPR: https://gdpr-text.com/read/article-45/#para_gdpr-a-45_2
(assessAdequacy(eu,C) <=
  gdpr(45,2,a,C),
  gdpr(45,2,b,C),
  gdpr(45,2,c,C))#c1.

% Article 45(3), GDPR: https://gdpr-text.com/read/article-45/#para_gdpr-a-45_3
(gdpr(45,3,adequateDecision(eu,C)) <=
  assessAdequacy(eu,C),
  implementingAct(C),
  providePeriodicReview(implementingAct(C)),
  specifyItsApplication(implementingAct(C)),
  gdpr(93,2,implementingAct(C)))#c1.

exception(gdpr(45,3,adequateDecision(eu,C)),applicable(implementingAct(C)))#c1.
exception(applicable(implementingAct(C)),identify(implementingAct(C),sa(SA,gdpr(45,2,b,C))))#c1.

% The following rule is not a part of Article 45(3), but we put it here for readability. It says "there is an adequate decision pursuant to Article 45(3) if there is the adequate decision and it is pursuant to the article".
(adequateDecision(eu,C,gdpr(45,3)) <=
  adequateDecision(eu,C),
  gdpr(45,3,adequateDecision(eu,C)))#c1.

% Article 46, gdpr
(ex_gdpr(44,transfer(S,G,Data)) <=
  gdpr(46,transfer(S,G,Data)))#c1.
(gdpr(46,transfer(S,G,Data)) <=
  gdpr(46,_,transfer(S,G,Data)))#c1.

% 46(1): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_1
(gdpr(46,1,transfer(S,G,Data)) <=
  countryOf(C,G),
  negation(adequateDecision(eu,C,gdpr(45,3))),
  ctrlPrcsr(X,transfer(S,G,Data),gdpr),
  subj(Subj,Data),
  enforceable(right(Subj)),
  effective(legalRemedy(Subj)),
  asg(X,transfer(S,G,Data)))#c1.

% 46(2): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2
(asg(X,transfer(S,G,Data)) <=
  gdpr(46,2,asg(X,transfer(S,G,Data))))#c1.
(gdpr(46,2,asg(X,transfer(S,G,Data))) <=
  gdpr(46,2,_,asg(X,transfer(S,G,Data))))#c1.

% 46(2)(a): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2a
(gdpr(46,2,a,asg(_,transfer(S,G,_))) <=
  pb(PB1,S),
  pb(PB2,G),
  inst(PB1,PB2),
  binding(inst(PB1,PB2)),
  enforceable(inst(PB1,PB2)))#c1.

% 46(2)(b): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2b
(gdpr(46,2,b,asg(_,transfer(S,G,Data))) <=
  gdpr(47,transfer(S,G,Data)))#c1.

% 46(2)(c): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2c
(gdpr(46,2,c,asg(_,transfer(S,G,Data))) <=
  adopt(eu,sdpc),
  apply(sdpc,transfer(S,G,Data)))#c1.

% 46(2)(d): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2d
(gdpr(46,2,d,asg(_,transfer(S,G,Data))) <=
  sa(SA,transfer(S,G,Data)),
  adopt(SA,sdpc),
  approve(eu,sdpc),
  apply(sdpc,transfer(S,G,Data)))#c1.

% 46(2)(e): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2e
(gdpr(46,2,e,asg(X,transfer(_,_,_))) <=
  codeOfConduct(X,gdpr(40)),
  binding(codeOfConduct(X,gdpr(40))),
  enforceable(codeOfConduct(X,gdpr(40))))#c1.

% 46(2)(f): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_2f
(gdpr(46,2,f,asg(X,transfer(_,_,_))) <=
  codeOfConduct(X,gdpr(42)),
  binding(codeOfConduct(X,gdpr(42))),
  enforceable(codeOfConduct(X,gdpr(42))))#c1.

% 46(3): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_3
(asg(X,transfer(S,G,Data)) <=
  gdpr(46,3,asg(X,transfer(S,G,Data))))#c1.
(gdpr(46,3,asg(X,transfer(S,G,Data))) <=
  gdpr(46,3,_,asg(X,transfer(S,G,Data))))#c1.

% 46(3)(a): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_3a
(gdpr(46,3,a,asg(X,transfer(S,G,Data))) <=
  sa(SA,transfer(S,G,Data)),
  authorize(SA,asg(X,transfer(S,G,Data))),
  ctrlPrcsr(Y,transfer(S,G,Data),gdpr),
  inThirdCountry(Y,eu),
  contractualClause(X,Y))#c1.
(gdpr(46,3,a,asg(X,transfer(S,G,Data))) <=
  sa(SA,transfer(S,G,Data)),
  authorize(SA,asg(X,transfer(S,G,Data))),
  recipient(Y,transfer(S,G,Data),gdpr),
  inThirdCountry(Y,eu),
  contractualClause(X,Y))#c1.

% 46(3)(b): https://gdpr-text.com/read/article-46/#para_gdpr-a-46_3b
(gdpr(46,3,b,asg(_,transfer(S,G,Data))) <=
  pb(PB1,S),
  pb(PB2,G),
  subj(Subj,Data),
  adminArrange(PB1,PB2,right(Subj)),
  enforceable(right(Subj)),
  effective(right(Subj)))#c1.

% Article 49, GDPR
% 49(1): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1
(ex_gdpr(44,transfer(S,G,Data)) <=
  gdpr(49,_,transfer(S,G,Data)))#c1.
(gdpr(49,1,transfer(S,G,Data)) <=
  countryOf(C,G),
  negation(adequateDecision(eu,C,gdpr(45,3))),
  ctrlPrcsr(X,transfer(S,G,Data),gdpr),
  negation(asg(X,transfer(S,G,Data))),
  gdpr(49,1,_,transfer(S,G,Data)))#c1.

% 49(1)(a): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1a
(gdpr(49,1,a,transfer(S,G,Data)) <=
  subj(Subj,Data),
  consent(Subj,transfer(S,G,Data)),
  knowRiskBeforeConsent(Subj,transfer(S,G,Data),consent(Subj,transfer(S,G,Data))))#c1.

% 49(1)(b): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1b
(gdpr(49,1,b,transfer(S,G,Data)) <=
  subj(Subj,Data),
  ctrlr(X,transfer(S,G,Data),gdpr),
  contract(Contract,Subj,X),
  need(performance(Contract),transfer(S,G,Data)))#c1.
(gdpr(49,1,b,transfer(S,G,Data)) <=
  subj(Subj,Data),
  ctrlr(X,transfer(S,G,Data),gdpr),
  preContMeasure(Measure,Subj,X),
  need(implement(Measure),transfer(S,G,Data)))#c1.

% 49(1)(c): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1c
(gdpr(49,1,c,transfer(S,G,Data)) <=
  subj(Subj,Data),
  ctrlr(X,transfer(S,G,Data),gdpr),
  person(Y),
  contract(Contract,X,Y),
  inInterestOf(Contract,Subj),
  need(conclusion(Contract),transfer(S,G,Data)))#c1.
(gdpr(49,1,c,transfer(S,G,Data)) <=
  subj(Subj,Data),
  ctrlr(X,transfer(S,G,Data),gdpr),
  person(Y),
  contract(Contract,X,Y),
  inInterestOf(Contract,Subj),
  need(performance(Contract),transfer(S,G,Data)))#c1.

% 49(1)(d): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1d
(gdpr(49,1,d,transfer(S,G,Data)) <=
  need(interest(public),transfer(S,G,Data)))#c1.

% 49(1)(e): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1e
(gdpr(49,1,e,transfer(S,G,Data)) <=
  legalClaim(Claim),
  need(establish(Claim),transfer(S,G,Data)))#c1.
(gdpr(49,1,e,transfer(S,G,Data)) <=
  legalClaim(Claim),
  need(exercise(Claim),transfer(S,G,Data)))#c1.
(gdpr(49,1,e,transfer(S,G,Data)) <=
  legalClaim(Claim),
  need(defence(Claim),transfer(S,G,Data)))#c1.

% 49(1)(f): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1f
(gdpr(49,1,f,transfer(S,G,Data)) <=
  subj(Subj,Data),
  negation(canConsent(Subj,transfer(S,G,Data))),
  need(protect(Subj),
  transfer(S,G,Data)))#c1.
(gdpr(49,1,f,transfer(S,G,Data)) <=
  subj(Subj,Data),
  negation(canConsent(Subj,transfer(S,G,Data))),
  diffPerson(Y,Subj),
  need(protect(Y),transfer(S,G,Data)))#c1.

% 49(1)(g): https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_1g
(gdpr(49,1,g,transfer(S,G,Data)) <=
  register(X),
  provideInfo(X,public,transfer(S,G,Data)),
  canConsult(public,X,transfer(S,G,Data)),
  canDemonstrate(Persons,interest(Persons)),
  legitimate(interest(Persons)),
  canConsult(Persons,X,transfer(S,G,Data)),
  fulfill(X,lawForConsultation(eu)),
  fulfill(X,lawForConsultation(memberState)),
  need(X,transfer(S,G,Data)))#c1.

% 49(1)'s last condition: https://gdpr-text.com/read/article-49/#para_gdpr-a-49_1_2
(gdpr(49,1,last,transfer(S,G,Data)) <=
  negation(gdpr(45,1,transfer(S,G,Data))),
  negation(gdpr(46,transfer(S,G,Data))),
  negation(gdpr(47,transfer(S,G,Data))),
  negation(gdpr(49,1,a,transfer(S,G,Data))),
  negation(gdpr(49,1,b,transfer(S,G,Data))),
  negation(gdpr(49,1,c,transfer(S,G,Data))),
  negation(gdpr(49,1,d,transfer(S,G,Data))),
  negation(gdpr(49,1,e,transfer(S,G,Data))),
  negation(gdpr(49,1,f,transfer(S,G,Data))),
  negation(gdpr(49,1,g,transfer(S,G,Data))),
  subj(Subj,Data),
  ctrlr(X,transfer(S,G,Data),gdpr),
  negation(repetitive(transfer(S,G,Data))),
  limitedNumber(Subj),
  need(interest(X),transfer(S,G,Data)),
  compelling(interest(X)),
  legitimate(interest(X)),
  negation(override(right(Subj),interest(X))),
  negation(override(freedom(Subj),interest(X))),
  assessCircum(X,transfer(S,G,Data)),
  sg(X,assessCircum(X,transfer(S,G,Data))),
  sa(SA,transfer(S,G,Data)),
  inform(X,SA,transfer(S,G,Data)),
  inform(X,Subj,transfer(S,G,Data)),
  inform(X,Subj,interest(X)))#c1.

% facts used for application of AGRAL, APPI, GDPR
fact(transfer(o(ja),o(c1),data(empl(o(ja))))#_).
fact(transfer(o(c1),o(c2),data(empl(o(ja))))#_).
fact(subj(empl(o(ja)),data(empl(o(ja))))#_).
fact(subj(empl(o(c1)),data(empl(o(c1))))#_).
fact(subj(empl(o(c2)),data(empl(o(c2))))#_).
fact(countryOf(ja,o(ja))#_).
fact(countryOf(c1,o(c1))#_).
fact(countryOf(c2,o(c2))#_).

% facts used for application of AGRAL
fact(plaintiff(empl(o(ja)))#_).
fact(defendant(co)#_).
fact(jurisAct(cj1,empl(o(ja)),co)#ja).
fact(jurisAct(c12,empl(o(ja)),co)#ja).
fact(choseAtThatTime(parties(cj1),ja)#_).
fact(choseAtThatTime(parties(c12),c1)#_).

% facts used for application of APPI
fact(operator(o(ja),transfer(o(ja),o(c1),data(empl(o(ja)))),appi)#_).
fact(operator(o(c1),transfer(o(c1),o(c2),data(empl(o(ja)))),appi)#_).
fact(recipient(o(c1),transfer(o(ja),o(c1),data(empl(o(ja)))),appi)#_).
fact(recipient(o(c2),transfer(o(c1),o(c2),data(empl(o(ja)))),appi)#_).
fact(inThirdCountry(o(c1),ja)#_).
fact(inThirdCountry(o(c2),ja)#_).

% facts used for application of GDPR
fact(ctrlr(o(ja),transfer(o(ja),o(c1),data(empl(o(ja)))),gdpr)#_).
fact(ctrlr(o(c1),transfer(o(c1),o(c2),data(empl(o(ja)))),gdpr)#_).
fact(ctrlPrcsr(o(ja),transfer(o(ja),o(c1),data(empl(o(ja)))),gdpr)#_).
fact(ctrlPrcsr(o(c1),transfer(o(c1),o(c2),data(empl(o(ja)))),gdpr)#_).
fact(recipient(o(c1),transfer(o(ja),o(c1),data(empl(o(ja)))),gdpr)#_).
fact(recipient(o(c2),transfer(o(c1),o(c2),data(empl(o(ja)))),gdpr)#_).
fact(inThirdCountry(o(ja),eu)#_).
fact(inThirdCountry(o(c2),eu)#_).
fact(contract(c12,empl(o(ja)),o(ja))#_).

% The following list is based on "https://ec.europa.eu/info/law/law-topic/data-protection/international-dimension-data-protection/adequacy-decisions_en" at 11:17(JST), 08/03/2022
fact(adequateDecision(eu,andorra)#_).
fact(adequateDecision(eu,argentina)#_).
fact(adequateDecision(eu,canada_commercialOrganizations)#_).
fact(adequateDecision(eu,faroeIslands)#_).
fact(adequateDecision(eu,guernsey)#_).
fact(adequateDecision(eu,israel)#_).
fact(adequateDecision(eu,isleOfMan)#_).
fact(adequateDecision(eu,ja)#_). % japan
fact(adequateDecision(eu,jersey)#_).
fact(adequateDecision(eu,newZealand)#_).
fact(adequateDecision(eu,republicOfKorea)#_).
fact(adequateDecision(eu,switzerLand)#_).
fact(adequateDecision(eu,uk_underGDPRandLED)#_).
fact(adequateDecision(eu,uruguay)#_).