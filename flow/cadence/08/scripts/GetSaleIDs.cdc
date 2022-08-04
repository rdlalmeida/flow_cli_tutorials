import ExampleToken from "../../06/contracts/ExampleToken.cdc"
import ExampleNFT from "../../05/contracts/ExampleNFT.cdc"
import ExampleMarketplace from "../contracts/ExampleMarketplace.cdc"

// This script prints the NFTs that input account has for sale
pub fun main(targetAddress: Address) {
    // Get the public account
    let account = getAccount(targetAddress)

    // Find the public Sale reference to their Collection. Fetch it as an optional first to test its existence before attempting to operate on it 
    var accountSalesReference: &ExampleMarketplace.SaleCollection{ExampleMarketplace.SalePublic}? 
        = account.getCapability<&ExampleMarketplace.SaleCollection{ExampleMarketplace.SalePublic}>(ExampleMarketplace.SalePublicPath).borrow()

    if (accountSalesReference == nil) {
        panic(
            "Unable to find a Sale Collection for account "
            .concat(targetAddress.toString())
        )
    }
    else {
        // There is a Sale Collection stored in a public path. Remove the optional and move on
        let accountSalesReference = (accountSalesReference as &ExampleMarketplace.SaleCollection{ExampleMarketplace.SalePublic}?)!

        // Log the NFTs that are for sale
        let accountNFTIDs: [UInt64] = accountSalesReference.getIDs()
        var index = 1
        log("Account '".concat(targetAddress.toString()).concat("' NFTs for sale:"))
        for nftID in accountNFTIDs {
            log(
                "NFT #"
                .concat(index.toString())
                .concat(":")
            )

            let index = index + 1

            log(
                "ID: "
                .concat(nftID.toString())
                .concat(", Prince = ")
                .concat(accountSalesReference.idPrice(tokenID: nftID)!.toString())
                .concat("tokens!")
            )
        }
    }
}