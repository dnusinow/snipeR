proc.string.alias.table <- function(tab) {
  sym.recs <- tab[grep("Ensembl_UniProt_GN", tab$source),]
  desc.recs <- tab[grep("Ensembl_UniProt_DE", tab$source),]
  all.ids <- unique(sort(tab$protein))

  new.tab <- data.frame(ID = all.ids,
                        GeneSym =  sym.recs[match(all.ids, sym.recs$protein),"alias"],
                        GeneDesc = desc.recs[match(all.ids, desc.recs$protein), "alias"])
  return(new.tab)
}
