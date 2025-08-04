// TypeScript Anchor Client Example (roughly equivalent)
import * as anchor from '@coral-xyz/anchor';
import { Connection, PublicKey, Keypair } from '@solana/web3.js';

export class SolanaService {
  private program: anchor.Program<any>;
  private provider: anchor.AnchorProvider;

  async initializeUser(): Promise<string> {
    // Get PDA
    const [userProfilePDA] = PublicKey.findProgramAddressSync(
      [
        Buffer.from("USER_STATE"),
        this.provider.wallet.publicKey.toBuffer(),
      ],
      this.program.programId
    );

    // Call method - TypeScript version
    const signature = await this.program.methods
      .initializeUser()
      .accounts({
        authority: this.provider.wallet.publicKey,
        userProfile: userProfilePDA,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();

    return signature;
  }

  async addTodo(content: string): Promise<string> {
    const [userProfilePDA] = PublicKey.findProgramAddressSync(/*...*/);
    const [todoAccountPDA] = PublicKey.findProgramAddressSync(/*...*/);

    const signature = await this.program.methods
      .addTodo(content)
      .accounts({
        userProfile: userProfilePDA,
        todoAccount: todoAccountPDA,
        authority: this.provider.wallet.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();

    return signature;
  }

  async fetchUserProfile(): Promise<any> {
    const [userProfilePDA] = PublicKey.findProgramAddressSync(/*...*/);
    return await this.program.account.userProfile.fetch(userProfilePDA);
  }
}
