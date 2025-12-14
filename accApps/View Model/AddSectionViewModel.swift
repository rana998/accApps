import SwiftUI
import Combine

final class AddSectionViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedIcon: String = "star"
    @Published var customIconName: String = ""
    @Published var selectedColor: Color = .blue
    
    // Suggested sets
    let suggestedIcons: [String] = [
        "house","house.fill","house.circle","house.circle.fill",
        "building","building.fill","building.2","building.2.fill",
        "star","star.fill","star.circle","star.circle.fill","star.leadinghalf.filled",
        "heart","heart.fill","heart.circle","heart.circle.fill","heart.slash",
        "bolt","bolt.fill","bolt.circle","bolt.circle.fill","bolt.slash",
        "flame","flame.fill","drop","drop.fill","leaf","leaf.fill",
        "pawprint","pawprint.fill","ant","ant.fill","ladybug","ladybug.fill",
        "tortoise","tortoise.fill","hare","hare.fill","fish","fish.fill",
        "music.note","music.note.list","music.mic","music.mic.fill","waveform",
        "play","play.fill","pause","pause.fill","stop","stop.fill",
        "forward","forward.fill","backward","backward.fill","shuffle","repeat","repeat.1",
        "speaker","speaker.fill","speaker.wave.1","speaker.wave.2","speaker.wave.3","speaker.slash",
        "headphones","earpods","airpods","airpodspro","airpodsmax",
        "book","book.fill","book.closed","book.closed.fill","books.vertical","books.vertical.fill",
        "bookmark","bookmark.fill","bookmark.circle","bookmark.circle.fill",
        "folder","folder.fill","folder.circle","folder.circle.fill","folder.badge.plus",
        "doc","doc.fill","doc.text","doc.text.fill","doc.on.doc","doc.on.doc.fill",
        "tray","tray.fill","tray.and.arrow.up","tray.and.arrow.down",
        "archivebox","archivebox.fill","paperplane","paperplane.fill",
        "bubble.left","bubble.left.fill","bubble.right","bubble.right.fill",
        "message","message.fill","message.circle","message.circle.fill",
        "envelope","envelope.fill","envelope.open","envelope.open.fill",
        "phone","phone.fill","phone.circle","phone.circle.fill","phone.down","phone.down.fill",
        "bell","bell.fill","bell.slash","bell.slash.fill","bell.badge",
        "flag","flag.fill","flag.circle","flag.circle.fill",
        "location","location.fill","location.circle","location.circle.fill",
        "map","map.fill","mappin","mappin.circle","mappin.circle.fill",
        "globe","globe.europe.africa","globe.americas","globe.asia.australia",
        "person","person.fill","person.circle","person.circle.fill",
        "person.crop.square","person.crop.square.fill",
        "person.2","person.2.fill","person.3","person.3.fill",
        "hand.thumbsup","hand.thumbsup.fill","hand.thumbsdown","hand.thumbsdown.fill",
        "hand.raised","hand.raised.fill","hand.tap","hand.point.up",
        "eye","eye.fill","eye.slash","eye.slash.fill",
        "lock","lock.fill","lock.open","lock.open.fill",
        "key","key.fill","shield","shield.fill","shield.lefthalf.fill",
        "exclamationmark.triangle","exclamationmark.triangle.fill",
        "info.circle","info.circle.fill","questionmark.circle","questionmark.circle.fill",
        "gear","gearshape","gearshape.fill","slider.horizontal.3",
        "ellipsis","ellipsis.circle","ellipsis.circle.fill","ellipsis.vertical",
        "plus","plus.circle","plus.circle.fill","minus","minus.circle","minus.circle.fill",
        "xmark","xmark.circle","xmark.circle.fill",
        "checkmark","checkmark.circle","checkmark.circle.fill",
        "arrow.left","arrow.right","arrow.up","arrow.down",
        "arrow.up.right","arrow.down.left","arrow.clockwise","arrow.counterclockwise",
        "chevron.left","chevron.right","chevron.up","chevron.down",
        "sun.max","sun.max.fill","sunrise","sunset",
        "moon","moon.fill","moon.stars","moon.stars.fill",
        "cloud","cloud.fill","cloud.rain","cloud.rain.fill",
        "cloud.bolt","cloud.bolt.fill","cloud.snow","wind","snow",
        "camera","camera.fill","camera.circle","camera.circle.fill",
        "photo","photo.fill","photo.on.rectangle","photo.stack",
        "film","film.fill","video","video.fill","video.circle","video.circle.fill",
        "tv","tv.fill","display","desktopcomputer",
        "iphone","ipad","ipad.landscape","macbook",
        "keyboard","keyboard.fill","printer","printer.fill",
        "cart","cart.fill","cart.circle","cart.circle.fill",
        "creditcard","creditcard.fill","banknote","banknote.fill",
        "bag","bag.fill","bag.circle","bag.circle.fill",
        "clock","clock.fill","alarm","alarm.fill","timer",
        "calendar","calendar.circle","calendar.circle.fill",
        "chart.bar","chart.bar.fill","chart.line.uptrend.xyaxis",
        "sparkles","wand.and.stars","lightbulb","lightbulb.fill",
        "square","square.fill","square.circle","square.circle.fill",
        "rectangle","rectangle.fill","rectangle.roundedtop","rectangle.roundedbottom",
        "rectangle.split.2x1","rectangle.split.3x1","rectangle.split.2x2",
        "rectangle.stack","rectangle.stack.fill","rectangle.stack.badge.plus",
        "circle","circle.fill","circle.lefthalf.fill","circle.righthalf.fill",
        "capsule","capsule.fill","capsule.portrait","capsule.portrait.fill",
        
        "grid","grid.circle","grid.circle.fill",
        "square.grid.2x2","square.grid.2x2.fill",
        "square.grid.3x3","square.grid.3x3.fill",
        "square.grid.4x3.fill",
        
        "line.3.horizontal","line.3.horizontal.circle","line.3.horizontal.circle.fill",
        "line.horizontal.3.decrease","line.horizontal.3.decrease.circle",
        "line.horizontal.3.decrease.circle.fill",
        
        "text.alignleft","text.aligncenter","text.alignright","text.justify",
        "textformat","textformat.size","textformat.bold","textformat.italic",
        "textformat.underline","textformat.strikethrough",
        
        "bold","italic","underline","strikethrough",
        "text.cursor","text.insert","text.append","text.badge.plus",
        
        "scissors","scissors.badge.ellipsis",
        "doc.badge.plus","doc.badge.gearshape","doc.badge.clock",
        "doc.richtext","doc.plaintext","doc.zipper",
        
        "folder.badge.minus","folder.badge.person.crop",
        "folder.badge.gear","folder.badge.questionmark",
        
        "externaldrive","externaldrive.fill",
        "externaldrive.badge.plus","externaldrive.badge.minus",
        "externaldrive.badge.person.crop",
        
        "internaldrive","internaldrive.fill",
        "opticaldisc","opticaldisc.fill",
        "memorychip","cpu","gpu",
        
        "wifi","wifi.slash","wifi.exclamationmark",
        "antenna.radiowaves.left.and.right",
        "network","personalhotspot",
        
        "battery.100","battery.75","battery.50","battery.25","battery.0",
        "battery.charging","battery.slash",
        
        "power","power.circle","power.circle.fill",
        "bolt.horizontal","bolt.horizontal.fill",
        
        "trash","trash.fill","trash.circle","trash.circle.fill",
        "trash.slash",
        
        "pencil","pencil.circle","pencil.circle.fill",
        "pencil.slash","highlighter","eraser",
        
        "paintbrush","paintbrush.fill","paintpalette","paintpalette.fill",
        
        "ruler","ruler.fill","level","level.fill",
        
        "hammer","hammer.fill","wrench","wrench.fill",
        "screwdriver","screwdriver.fill",
        
        "bandage","bandage.fill","cross","cross.fill",
        "cross.case","cross.case.fill",
        "heart.text.square","heart.text.square.fill",
        
        "stethoscope","pills","pills.fill",
        
        "figure.walk","figure.walk.circle","figure.walk.circle.fill",
        "figure.run","figure.stand","figure.roll",
        "figure.wave","figure.fall",
        
        "figure.seated.side","figure.cooldown",
        "figure.mind.and.body",
        
        "graduationcap","graduationcap.fill",
        "backpack","backpack.fill",
        "studentdesk","books.vertical.circle",
        
        "ticket","ticket.fill",
        "theatermasks","theatermasks.fill",
        "gamecontroller","gamecontroller.fill",
        
        "die.face.1","die.face.2","die.face.3",
        "die.face.4","die.face.5","die.face.6",
        
        "puzzlepiece","puzzlepiece.fill",
        "cube","cube.fill","shippingbox","shippingbox.fill",
        
        "car","car.fill","bus","bus.fill",
        "tram","tram.fill","airplane","airplane.circle.fill",
        
        "bicycle","bicycle.circle","bicycle.circle.fill",
        
        "fuelpump","fuelpump.fill",
        "speedometer","gauge","gauge.medium","gauge.high",
        
        "leaf.arrow.circlepath",
        "arrow.triangle.2.circlepath",
        "arrow.uturn.left","arrow.uturn.right",
        "arrow.uturn.up","arrow.uturn.down",
        
        "repeat.circle","repeat.circle.fill",
        "shuffle.circle","shuffle.circle.fill",
        
        "magnifyingglass","magnifyingglass.circle","magnifyingglass.circle.fill",
        "plus.magnifyingglass","minus.magnifyingglass",
        
        "sparkle","sparkles.rectangle.stack",
        "wand.and.rays","wand.and.rays.inverse",
        
        "face.smiling","face.smiling.fill",
        "face.dashed","faceid",
        "touchid",
        
        "brain","brain.head.profile",
        "ear.badge.checkmark","ear.trianglebadge.exclamationmark",
        
        "waveform.circle","waveform.circle.fill",
        "mic","mic.fill","mic.slash","mic.slash.fill",
        
        "square.and.arrow.up","square.and.arrow.up.fill",
        "square.and.arrow.down","square.and.arrow.down.fill",
        "square.and.arrow.up.on.square","square.and.arrow.down.on.square",
        "rectangle.and.arrow.up.right.and.arrow.down.left",
        "rectangle.and.arrow.up.right.and.arrow.down.left.slash",
        
        "arrowshape.turn.up.left","arrowshape.turn.up.right",
        "arrowshape.turn.up.left.circle","arrowshape.turn.up.left.circle.fill",
        "arrowshape.turn.up.right.circle","arrowshape.turn.up.right.circle.fill",
        "arrowshape.zigzag.right","arrowshape.bounce.right",
        
        "chart.pie","chart.pie.fill",
        "chart.bar.xaxis","chart.bar.doc.horizontal",
        "chart.bar.doc.horizontal.fill",
        "chart.dots.scatter","chart.xyaxis.line",
        
        "timer.square","clock.arrow.circlepath",
        "stopwatch","stopwatch.fill",
        "hourglass","hourglass.bottomhalf.fill","hourglass.tophalf.fill",
        
        "calendar.badge.plus","calendar.badge.minus",
        "calendar.badge.clock","calendar.badge.exclamationmark",
        
        "text.bubble","text.bubble.fill",
        "character","character.cursor.ibeam",
        "a.magnify","text.magnifyingglass",
        
        "signature","scribble","lasso","lasso.and.sparkles",
        
        "shield.checkerboard","shield.checkmark","shield.slash",
        "lock.rectangle","lock.rectangle.fill",
        
        "person.badge.plus","person.badge.minus",
        "person.badge.checkmark","person.badge.xmark",
        "person.wave.2","person.line.dotted.person",
        
        "person.fill.turn.right","person.fill.turn.left",
        "person.crop.circle.badge.plus","person.crop.circle.badge.checkmark",
        
        "hand.point.left","hand.point.right",
        "hand.draw","hand.draw.fill",
        "hand.wave","hand.wave.fill",
        
        "globe.badge.chevron.backward","globe.badge.chevron.forward",
        "network.badge.shield.half.filled",
        
        "wifi.circle","wifi.circle.fill",
        "bolt.circle","bolt.circle.fill",
        
        "battery.100.bolt","battery.50","battery.25",
        "battery.0","battery.exclamationmark",
        
        "icloud","icloud.fill",
        "icloud.and.arrow.up","icloud.and.arrow.down",
        "icloud.slash","icloud.slash.fill",
        
        "server.rack","server.rack.fill",
        "externaldrive.connected.to.line.below",
        "externaldrive.connected.to.line.below.fill",
        
        "barcode","barcode.viewfinder",
        "qrcode","qrcode.viewfinder",
        
        "cart.badge.plus","cart.badge.minus",
        "creditcard.circle","creditcard.circle.fill",
        
        "tag","tag.fill","tag.circle","tag.circle.fill",
        
        "ticket.circle","ticket.circle.fill",
        
        "location.north","location.north.fill",
        "location.north.circle","location.north.circle.fill",
        
        "binoculars","binoculars.fill",
        "scope","scope.fill",
        
        "sun.min","sun.min.fill",
        "sun.dust","sun.dust.fill",
        "sun.haze","sun.haze.fill",
        
        "cloud.fog","cloud.fog.fill",
        "cloud.drizzle","cloud.drizzle.fill",
        "cloud.heavyrain","cloud.heavyrain.fill",
        
        "thermometer.sun","thermometer.snowflake",
        "humidity","humidity.fill",
        
        "moon.zzz","moon.zzz.fill",
        
        "snowflake","tornado.circle","tornado.circle.fill",
        
        "car.circle","car.circle.fill",
        "car.2","car.2.fill",
        "bus.doubledecker","bus.doubledecker.fill",
        
        "sailboat","sailboat.fill",
        "ferry","ferry.fill",
        
        "figure.hiking","figure.hiking.circle","figure.hiking.circle.fill",
        "figure.yoga","figure.strengthtraining.traditional",
        
        "dumbbell","dumbbell.fill",
        "sportscourt","sportscourt.fill",
        
        "gamecontroller.circle","gamecontroller.circle.fill",
        "joystick","joystick.fill",
        
        "headlight.low.beam","headlight.high.beam",
        "headlight.fog","headlight.fog.fill",
        
        "sparkles.tv","sparkles.rectangle.stack.fill",
        
        "face.smiling.inverse","faceid.dotted",
        "person.crop.square.filled.and.at.rectangle",
        
        "waveform.path.ecg","waveform.path.ecg.rectangle",
        "waveform.path.ecg.rectangle.fill",
        
        "mic.badge.plus","mic.badge.xmark",
        
        "speaker.badge.exclamationmark",
        "speaker.zzz",
        
        "lightswitch.on","lightswitch.on.fill",
        "lightswitch.off","lightswitch.off.fill",
        
        "fan","fan.fill",
        "fan.ceiling","fan.ceiling.fill",
        
        "powerplug","powerplug.fill",
        "poweroutlet.type.a","poweroutlet.type.c",
        
        "lamp.table","lamp.table.fill",
        "lamp.desk","lamp.desk.fill",
        
        "sofa","sofa.fill",
        "bed.double","bed.double.fill",
        
        "washer","washer.fill",
        "dryer","dryer.fill",
        
        "fork.knife","fork.knife.circle","fork.knife.circle.fill",
        
        "cup.and.saucer","cup.and.saucer.fill",
        "takeoutbag.and.cup.and.straw",
        
        "birthday.cake","birthday.cake.fill",
        
        "scalemass","scalemass.fill",
        "scales","scales.fill",
        
        "hammer.circle","hammer.circle.fill",
        "wrench.and.screwdriver","wrench.and.screwdriver.fill"
    ]
    
    let suggestedColors: [Color] = [.lightOrange, .creamYellow, .grass, .lightBlue, .lightPurple, .whitiesh]
    
    var effectiveIconName: String {
        let trimmed = customIconName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? selectedIcon : trimmed
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !(effectiveIconName.isEmpty) &&
        selectedColor.toHex() != nil
    }
}
