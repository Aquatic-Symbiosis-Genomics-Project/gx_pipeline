# gx_pipeline
wrapper for the [NCBI FCS pipeline](https://github.com/ncbi/fcs/wiki/)

These are wrappers to run the Singularity version of the NCBI FCS_genome pipeline at Sanger

## 0.5.5 Remarks
that is the current version at NCBI

## 0.3.0 Remarks

With 0.3.0, you should see a decrease in false positives. The “classify” step now dynamically assesses which division(s) are likely to be primary (non-contaminant), and also adjusts the threshold. So if you’re running an assembly that is poorly represented in the database, it’ll require higher coverage hits. And the noise that we sometimes get in metazoa to insects, fish, etc is better recognized as FPs and excluded.
