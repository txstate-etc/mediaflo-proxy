import Server, { HttpError } from 'fastify-txstate'
import db from 'mssql-async/db'
import { Builder } from 'xml2js'
const builder = new Builder()

const server = new Server()
server.app.get('/:id', async (req, res) => {
  const m = req.query.url.match(/\/(watch|permalinks)\/(.*?)\//i)
  const id = m ? m[2] : req.query.url
  const maxheight = parseInt(req.query.maxheight ?? '0')
  const maxwidth = parseInt(req.query.maxwidth ?? '0')
  const xml = req.query.format === 'xml'
  const video = await db.getrow<{ id: string, shortId: string }>(`
    SELECT v.ShortContentID as shortId, v.videoID as id
    FROM Permalinks p
    INNER JOIN Videos v ON v.videoID=p.ReferenceID
    WHERE PermalinkID=@id
  `, { id: id })
  if (!video) throw new HttpError(404)
  let encoding = await db.getrow<{ width: number, height: number }>(
    'SELECT MAX(Width) as width, MAX(Height) as height FROM Encodings WHERE VideoID=@id GROUP BY VideoID',
    { id: video.id }
  )
  if (!encoding) encoding = { width: 1920, height: 1080 }
  // currently, mediaflo always creates a 16/9 player, so the encoding width should reflect that
  encoding.width = encoding.height * 16.0 / 9.0

  const ar = encoding.width / encoding.height
  let finalwidth = 0
  let finalheight = 0
  if (maxwidth && !maxheight) {
    finalwidth = Math.min(encoding.width, maxwidth)
    finalheight = Math.round(finalwidth / ar)
  } else if (!maxwidth && maxheight) {
    finalheight = Math.min(encoding.height, maxheight)
    finalwidth = Math.round(finalheight * ar)
  } else if (maxwidth && maxheight) {
    const boxar = maxwidth / maxheight
    if (ar > boxar) { // too wide
      finalwidth = Math.min(encoding.width, maxwidth)
      finalheight = Math.round(finalwidth / ar)
    } else { // too tall
      finalheight = Math.min(encoding.height, maxheight)
      finalwidth = Math.round(finalheight * ar)
    }
  }

  const displaywidth = finalwidth || encoding.width
  const displayheight = finalheight || encoding.height

  const ret = {
    version: '1.0',
    type: 'video',
    width: displaywidth,
    height: displayheight,
    html: `<div style="position: relative; ${finalwidth ? `max-width: ${finalwidth}px; ` : ''}padding-bottom: ${(100 * displayheight / displaywidth).toFixed(3)}%; padding-top: 0px; height: 0; overflow: hidden; -webkit-overflow-scrolling: touch;">
  <iframe id="ensembleEmbeddedContent_${video.shortId}"
    src="https://${req.hostname}/hapi/v1/contents/${video.id}/plugin?width=${displaywidth}&height=${displayheight}&displayTitle=false&autoPlay=false&hideControls=false&showCaptions=false&displaySharing=false&displayAnnotations=false&displayAttachments=false&displayLinks=false&displayEmbedCode=false&displayDownloadIcon=false&displayMetaData=false&displayDateProduced=false&displayCaptionSearch=false"
    frameborder="0"
    style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
    scrolling="no"
    allowfullscreen>
  </iframe>
</div>`
  }

  if (req.query.test) res.type('text/html').send(`<!DOCTYPE html><html><head><title>Embed Test</title></head><body>${ret.html}</body></html>`)
  if (xml) res.type('text/xml').send(builder.buildObject({ oembed: ret }))
  else return ret
})
server.start().catch(e => console.error(e))
