#!/bin/bash

./compile.sh

erl -pa ./ebin -s tests run