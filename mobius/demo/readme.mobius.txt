NOT NEEDED: k3d image load ./mobiusdatasampler.12.2.tar -c mobius-mycluster

kubectl -n mobius apply -f job_datasampler_mobius12_all.yaml

kubectl -n mobius logs job-mobiusdatasampler-all-4jrkh

kubectl delete job/job-mobiusdatasampler-all -n mobius



kubectl -n mobius apply -f job_datasampler_mobius12_all_sleep.yaml

./MobiusRemoteCLI.sh ftijobsubmit -s Mobius -U ADMIN -r JOBLOGS --verbose -o JOBLOGS.txt
