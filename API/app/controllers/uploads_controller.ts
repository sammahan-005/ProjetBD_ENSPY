import type { HttpContext } from '@adonisjs/core/http'
import { randomUUID } from 'node:crypto'
import drive from '@adonisjs/drive/services/main'

export default class UploadsController {
  /**
   * Upload permanent d'un fichier média ou document
   */
  async store({ request, response }: HttpContext) {
    // Valider le fichier avec des règles strictes sur la taille (max 20MB) et les extensions
    const file = request.file('file', {
      size: '20mb',
      extnames: [
        'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
        'mp4', 'webm', 'ogg', 'mov',       // Vidéos
        'mp3', 'wav', 'm4a', 'ogg',        // Audio
        'pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx' // Documents
      ],
    })

    if (!file) {
      return response.badRequest({ error: 'Aucun fichier n\'a été fourni' })
    }

    if (!file.isValid) {
      return response.badRequest({ 
        error: 'Le fichier ne respecte pas les critères de validation', 
        errors: file.errors 
      })
    }

    // Générer un nom de fichier unique sécurisé avec UUID
    const key = `${randomUUID()}.${file.extname}`

    // Déplacer le fichier de son dossier temporaire vers le stockage Drive par défaut
    await file.moveToDisk(key)

    // Récupérer l'URL publique d'accès
    const url = await drive.use().getUrl(key)

    return response.ok({
      message: 'Fichier importé avec succès',
      filename: key,
      url: url,
    })
  }
}
