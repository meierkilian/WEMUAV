start %CD%\mlr --from %CD%\dummy.csv --fs comma --nidx put ("
  @maxnf = max(@maxnf, NF);
  @nf = NF;
  while(@nf < @maxnf) {
    @nf += 1;
    $[@nf] = ""
  }
")