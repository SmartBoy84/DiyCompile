#!/usr/bin/env node

if (process.argv.length == 1)
    console.log(`${process.argv[1].split("\/").at(-1)} <dir> <command> <files...>`)
else {

    let args = process.argv.slice(2)

    let directory = args.shift()
    let command = args.shift()

    console.log(JSON.stringify(args.map(a => ({ directory, "command": `${command} ${a}`, "file": a }))))
}