import { useWeb3Modal } from '@web3modal/wagmi/react'

export default function Component() {
  const { open, close } = useWeb3Modal()

  open({ view: 'Account' })
  //...
}
