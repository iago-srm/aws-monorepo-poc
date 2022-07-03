import { useRouter } from 'next/router'

const Articles = () => {
  const router = useRouter()
  const { artigo } = router.query

  return <p>Artigo: {artigo}</p>
}

export default Articles