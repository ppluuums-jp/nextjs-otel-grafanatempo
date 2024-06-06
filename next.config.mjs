/** @type {import('next').NextConfig} */
const nextConfig = {
    experimental: {
        outputStandalone: true,
        instrumentationHook: true,
    },
}

export default nextConfig
