# mprolegpil-usecase

Overview

This repository contains programs used in a paper under review: Takahiro Sawasaki and Ken Satoh and Aurore Clément Troussel. 2022. A Usecase on GDPR of Modular-PROLEG for Private International Law.

1. pil_interpreter_ai4legal.pl - The interpreter of Modular-PROLEG for PIL used in the paper.
2. usecase_ai4legal.pl - Program $\mathcal{P}_{1}$ of Modular-PROLEG for PIL used in the paper, which is an implementation of the reasoning in Case of Data Transfer.

## Requirement

Install SWI-Prolog (version 8.4.1 for windows 64 bit confirmed).

## Install

Place both 1 and 2 in the same directory.

## Usage

Run SWI-Prolog on the directory containing 1 and 2, then consult 1. Then

- ask t1 to the prompt if you want to confirm that
  claim(empl(o(ja)),co,inBreachOf(transfer(o(ja),o(c1),data(empl(o(ja)))),cj1))#ja is false.
- ask t2 to the prompt if you want to confirm that 
  claim(empl(o(ja)),co,inBreachOf(transfer(o(c1),o(c2),data(empl(o(ja)))),c12))#ja is true.

## Licence

See LICENSE.txt.

## Author

Ken Satoh (pil_interpreter_ai4legal.pl)

Takahiro Sawasaki (usecase_ai4legal.pl, README.md)
