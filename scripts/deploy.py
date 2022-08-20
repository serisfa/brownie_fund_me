from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import deploy_mocks, get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
def deploy_fund_me():
    account=get_account()
    print(f"Account:{account}")
    # pass the price feed adress to out fundme contract
    # if we are on a persistent network like Rinkeby, use the associated adress
    # otherwise, deploy MOCKS
    if network.show_active()not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_adress= config["networks"][network.show_active()]["eth_usd_price_feed"];
    else:
        deploy_mocks()
        price_feed_adress=MockV3Aggregator[-1].address
        print(f"Price Feed Adress:{price_feed_adress}")
    fund_me=FundMe.deploy(price_feed_adress, {"from":account}, publish_source = config["networks"][network.show_active()].get("verify"),)
    print(f"Contract deployed to {fund_me.address}")
    return fund_me
def main():
    deploy_fund_me()