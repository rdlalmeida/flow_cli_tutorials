/*
    ExampleNFT.cdc

    This is a complete version of the ExampleNFT contract that includes withdraw and deposit functionality, as well as a 
    collection resource that can be used to bundle NFTs together.
*/
pub contract ExampleNFT {
    /*
        Declare Path constants so paths do not have to be hardcoded in transactions and scripts
    */
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // Declare the NFT resource type
    pub resource NFT {
        // The unique ID that differentiates each NFT
        pub let id: UInt64

        // Initialize both fields in the init function
        init() {
            self.id = self.uuid
        }
    }

    /*
        We define this interface purely as a way to allow users to create public, restricted references to their NFT Collections.
        They would use this to publicly expose only the deposit, get IDs, and idExists fields in their Collection
    */
    pub resource interface NFTReceiver {
        pub fun deposit(token: @NFT)

        pub fun getIDs(): [UInt64]

        pub fun idExists(id: UInt64): Bool
    }

    // The definition of the Collection resource that holds the NFTs that a user owns
    pub resource Collection: NFTReceiver {
        // Dictionary of NFT conforming tokens NFT is a resource type with an 'UInt64' ID field
        pub var ownedNFTs: @{UInt64: NFT}

        // Initialize the NFTs field to an empty collection
        init() {
            self.ownedNFTs <- {}
        }

        /*
            Withdraw

            Function that removes an NFT from the collections and moves oit to the calling context
        */
        pub fun withdraw(withdrawID: UInt64): @NFT {
            // If the NFT isn't found, the transaction panics and reverts
            let token <- self.ownedNFTs.remove(key: withdrawID)!

            return <- token
        }

        /*
            Deposit

            Function that takes a NFT as an argument and adds it to the collections dictionary
        */
        pub fun deposit(token: @NFT) {
            // Add the new tokens to the dictionary with a force assignment if there is already a value at that key, it will fail and revert
            self.ownedNFTs[token.id] <-! token
        }

        /*
            idExists checks to see if a NFT with the given ID exists in the collection
        */
        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }

        /*
            getIDs returns an array of the IDs that are in the collection
        */
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // Creates a new empty Collection resource and returns it
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    /*
        mintNFT

        Function that mints a new NFT with a new ID and returns it to the caller
    */
    pub fun mintNFT(): @NFT {
        // Create a new NFT
        var newNFT <- create NFT()

        return <- newNFT
    }

    init() {
        self.CollectionStoragePath = /storage/nftTutorialCollection
        self.CollectionPublicPath = /public/nftTutorialCollection
        self.MinterStoragePath = /storage/nftTutorialMinter

        // Store an empty NFT Collection in account storage
        self.account.save(<- self.createEmptyCollection(), to: self.CollectionStoragePath)

        // Publish a reference to the Collection in storage
        self.account.link<&{NFTReceiver}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
    }
}