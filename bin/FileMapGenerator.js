#!/usr/bin/env node

if (process.argv.length == 2)
    console.log(`${process.argv[1].split("\/").at(-1)} <dir> <files...>`)
else {

    let args = process.argv.slice(2)
    let dir = args.shift().replaceAll("/", "\\/")

    console.log(JSON.stringify(args.reduce((a, b) => ({
        ...a, [b]: {
            "object": `${dir}\\/${b}.o`,
            "swift-dependencies": `${dir}\\/${b}.swiftdeps`,
            "dependencies": `${dir}\\/${b}.Td`
        }
    }),
        {
            "": // master
            {
                "dependencies": `${dir}\\/master.Td`,
                "swift-dependencies": `${dir}\\/master`
            }
        })
    ).replace(/\\\\/g, '\\') // dumb js
    )
}
