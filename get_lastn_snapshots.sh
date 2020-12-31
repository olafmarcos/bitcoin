#/bin/bash
#Setting initial values
maxbr=0 # Max_bid_rate
iterations=$1

last_bid=$(./pool --rpcserver=localhost:8443 --tlscertpath=./tls.cert --macaroonpath=~/.pool/mainnet/pool.macaroon auction snapshot)
prev_bid=$(echo "$last_bid" | grep prev_batch_id | cut -d '"' -f4)

# Setting function to get CPR from bid_id variable
function get_rate {
  bid=$(./pool --rpcserver=localhost:8443 --tlscertpath=./tls.cert --macaroonpath=~/.pool/mainnet/pool.macaroon auction snapshot --batch_id=$1)

  # Setting clearing_price_rate to $cpr
  cpr=$(echo "$bid" | grep clearing_price_rate | grep -o -E '[0-9]+')
  
  prev_bid=$(echo "$bid" | grep prev_batch_id | cut -d '"' -f4)
  echo $prev_bid " CPR: $cpr"

        if (( $cpr > $maxbr ))
        then
                maxbr=$cpr
        fi

        if (( $cpr != 0 ))
        then
                ((total++))
                sumbr=$(($sumbr + $cpr))
        fi
}

for i in $(eval echo {1..$iterations})
do
   get_rate $prev_bid
done

echo "Max Bid_Rate: "$maxbr
echo "Median Bid_rate: "$((sumbr/total))
