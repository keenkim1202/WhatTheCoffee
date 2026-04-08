import Foundation

enum CafeMapper {
  static func toEntity(_ object: Cafe) -> CafeEntity {
    CafeEntity(
      id: object._id.stringValue,
      name: object.name,
      visitDate: object.visitDate,
      comment: object.comment,
      rate: object.rate,
      latitude: object.latitude,
      longitude: object.longitude,
      isClosed: object.isClosed)
  }
}
