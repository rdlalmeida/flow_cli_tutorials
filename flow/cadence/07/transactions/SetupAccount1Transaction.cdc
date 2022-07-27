import ExampleToken from "../../06/contracts/ExampleToken.cdc"
import ExampleNFT from "../../05/contracts/ExampleNFT.cdc"

/*
    This transactions sets up the account that signs this transaction for the marketplace tutorial by publishing a Vault reference
    and creating an empty NFT Collection
*/
transaction() {
    prepare(account: AuthAccount) {
        // Create a public Receiver capability to the Vault. I can do this because the contract constructor guarantees a vault in storage for the signing account
        account.link<&ExampleToken.Vault{ExampleToken.Receiver, ExampleToken.Balance}>(ExampleToken.VaultPublicPath, target: ExampleToken.VaultStoragePath)

        log("Created Vault references")

        let referenceType: Type? = account.type(at: ExampleNFT.CollectionStoragePath)

        // Retrive a reference from a purposely non-existent path to force the variable to have the Never? type for comparison
        let nullValue = account.borrow<&ExampleNFT.Collection>(from: /storage/InexistentLocationOnPurpose)

        // Clean up the storage first. Try and retrieve a reference for any resource stored in the defined path
        // let collectionRef = account.borrow<&AnyResource>(from: ExampleNFT.CollectionStoragePath)
        // let collectionRef = account.borrow<&ExampleNFT.Collection>(from: /storage/InexistentPath)

        /* 
            I now have a reference from something already in storage that has the same type than the resource there: funny thing about references and resources in
            Cadence: a resource and the reference to THAT resource have the same data types! This is very useful to avoid pointless storage retrievals,
            as well reseting account states if a contract needs to be re-deployed (which in some cases is actually what is inteded).
            If there is a resource already in storage with the desired type, than the reference returned will have matching types (ExampleNFT.Collection)
            Otherwise, if there's nothing there and a Never? is returned instead
        */


        if (referenceType == nullValue.getType()) {
            log(
                "No ExampleNFT.Collection found in '"
                .concat(ExampleNFT.CollectionStoragePath.toString())
                .concat("' path. Creating and saving a new one!")
            )
            // If I get here, there was nothing in storage at that path. Carry on with creating and saving a new empty Collection to the path
            account.save<@ExampleNFT.Collection>(<- ExampleNFT.createEmptyCollection(), to: ExampleNFT.CollectionStoragePath)
        }
        else {
            /*
                The last instruction confirmed that there is some non-nil resource saved in that storage path. Since I've confirmed that it's
                not a dreaded 'Never?', which would trigger an error if I tried to force cast it with a '!' by running into a nil, I can now
                safely remove the optional '?' and test if the type obtained is the one I'm looking for
            */
            let normalizedReferenceType = referenceType!

            // Inform the user of the resource type found in storage
            log(
                "There's a '"
                .concat(normalizedReferenceType.identifier)
                .concat("' Resource stored in '")
                .concat(ExampleNFT.CollectionStoragePath.toString())
                .concat("' path")
            )

            // Create a brand new ExampleNFT.Collection for comparisson purposes (and for saving later if that turns out to be the case)
            let brandNewCollection: @ExampleNFT.Collection <- ExampleNFT.createEmptyCollection()

            if (brandNewCollection.getType() == normalizedReferenceType) {
                // The types match. This means that there's a reference of the desired type in storage already so there's no need to replace it
                // Destroy the new Collection resource and move on
                destroy brandNewCollection

                // Inform the user that the resource already exists in storage
                log(
                    "Found a '"
                    .concat(normalizedReferenceType.identifier)
                    .concat("' stored in '")
                    .concat(ExampleNFT.CollectionStoragePath.toString())
                    .concat(" already. Nothing else to do...")
                )
            }
            else {
                /* 
                    Something else other than a @ExampleNFT.Collection is that storage path. At this point, let's assume that our transaction is
                    more important and thus I need to load and destroy whatever is in there before replacing it for the brand new colletion
                */
                let randomResource <- account.load<@AnyResource>(from: ExampleNFT.CollectionStoragePath)

                // Log the resource type just for shit and giggles
                log(
                    "There was a '"
                    .concat(randomResource.getType().identifier)
                    .concat("' type resource in ")
                    .concat(ExampleNFT.CollectionStoragePath.toString())
                    .concat(" path... Destroying it")
                )

                destroy randomResource

                // Cool. The storage path is now free to receive a new resource. Fortunatelly, we already have one ready for that
                account.save<@ExampleNFT.Collection>(<- brandNewCollection, to: ExampleNFT.CollectionStoragePath)

                log(
                    "Stored a new '"
                    .concat(normalizedReferenceType.identifier)
                    .concat("' resource into '")
                    .concat(ExampleNFT.CollectionStoragePath.toString())
                    .concat("' path")
                )
            }
        }

        // Publish a capability to the Collection in storage, regardless on how that Collection got into storage
        account.link<&{ExampleNFT.NFTReceiver}>(ExampleNFT.CollectionPublicPath, target: ExampleNFT.CollectionStoragePath)

        log("Reference to a Collection in storage created!")
    }

    execute{
        }
}